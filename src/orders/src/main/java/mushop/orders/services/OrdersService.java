package mushop.orders.services;

import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import mushop.orders.config.OrdersConfigurationProperties;
import mushop.orders.entities.*;
import mushop.orders.repositories.CustomerOrderRepository;
import mushop.orders.resources.NewOrderResource;
import mushop.orders.values.OrderUpdate;
import mushop.orders.values.PaymentRequest;
import mushop.orders.values.PaymentResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.*;

import static mushop.orders.controllers.OrdersController.OrderFailedException;
import static mushop.orders.controllers.OrdersController.PaymentDeclinedException;

@Service
public class OrdersService {

    private final Logger LOG = LoggerFactory.getLogger(getClass());
    @Autowired
    private OrdersConfigurationProperties config;

    @Autowired
    private AsyncGetService asyncGetService;

    @Autowired
    private MessagingService messagingService;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @Autowired
    private MeterRegistry meterRegistry;

    @Value(value = "${http.timeout:5}")
    private long timeout;

    private ScheduledExecutorService cartDeleteExecutor = Executors.newScheduledThreadPool(5);


    public CustomerOrder createNewOrder(NewOrderResource orderPayload) {
        LOG.info("Creating order {}", orderPayload);
        LOG.debug("Starting calls");
        meterRegistry.counter("orders.placed").increment();
        try {
            Future<Address> addressFuture = asyncGetService.getObject(orderPayload.address,
                    new ParameterizedTypeReference<Address>() {
                    });
            Future<Customer> customerFuture = asyncGetService.getObject(orderPayload.customer,
                    new ParameterizedTypeReference<Customer>() {
                    });
            Future<Card> cardFuture = asyncGetService.getObject(orderPayload.card,
                    new ParameterizedTypeReference<Card>() {
                    });
            Future<List<Item>> itemsFuture = asyncGetService.getDataList(orderPayload.items,
                    new ParameterizedTypeReference<List<Item>>() {
                    });
            LOG.debug("End of calls.");

            //Calculate total
            float amount = calculateTotal(itemsFuture.get(timeout, TimeUnit.SECONDS));

            // Call payment service to make sure they've paid
            PaymentRequest paymentRequest = new PaymentRequest(
                    addressFuture.get(timeout, TimeUnit.SECONDS),
                    cardFuture.get(timeout, TimeUnit.SECONDS),
                    customerFuture.get(timeout, TimeUnit.SECONDS),
                    amount);

            LOG.info("Sending payment request: " + paymentRequest);
            Future<PaymentResponse> paymentFuture = asyncGetService.postResource(
                    config.getPaymentUri(),
                    paymentRequest,
                    new ParameterizedTypeReference<PaymentResponse>() {
                    });
            PaymentResponse paymentResponse = paymentFuture.get(timeout, TimeUnit.SECONDS);
            
            LOG.info("Received payment response: " + paymentResponse);
            if (paymentResponse == null) {
                meterRegistry.counter("orders.rejected","cause","payment_response_invalid").increment();
                throw new PaymentDeclinedException("Unable to parse authorisation packet");
            }
            if (!paymentResponse.isAuthorised()) {
                meterRegistry.counter("orders.rejected","cause","payment_declined").increment();
                throw new PaymentDeclinedException(paymentResponse.getMessage());
            }

            //Persist
            CustomerOrder order = new CustomerOrder(
                    null,
                    customerFuture.get(timeout, TimeUnit.SECONDS),
                    addressFuture.get(timeout, TimeUnit.SECONDS),
                    cardFuture.get(timeout, TimeUnit.SECONDS),
                    itemsFuture.get(timeout, TimeUnit.SECONDS),
                    null,
                    Calendar.getInstance().getTime(),
                    amount);
            LOG.debug("Received data: " + order.toString());

            CustomerOrder savedOrder = customerOrderRepository.save(order);
            LOG.debug("Saved order: " + savedOrder);
            meterRegistry.summary("orders.amount").record(amount);
            DistributionSummary.builder("order.stats")
                    .serviceLevelObjectives(10d,20d,30d,40d,50d,60d,70d,80d,90d,100d,110d)
                    //.publishPercentileHistogram()
                    .maximumExpectedValue(120d)
                    .minimumExpectedValue(5d)
                    .register(meterRegistry)
                    .record(amount);
            OrderUpdate update = new OrderUpdate(savedOrder.getId(), null);
            messagingService.dispatchToFulfillment(update);
            return savedOrder;
        } catch (TimeoutException e) {
            meterRegistry.counter("orders.rejected","cause","timeout").increment();
            throw new OrderFailedException("Unable to create order due to timeout from one of the services.", e);
        } catch (InterruptedException e) {
            meterRegistry.counter("orders.rejected","cause","interrupted").increment();
            throw new OrderFailedException("Unable to create order due to unspecified IO error.", e);
        }catch ( IOException  e) {
            meterRegistry.counter("orders.rejected","cause","connectivity").increment();
            throw new OrderFailedException("Unable to create order due to unspecified IO error.", e);
        }catch (ExecutionException e) {
            meterRegistry.counter("orders.rejected","cause","task_failed").increment();
            throw new OrderFailedException("Unable to create order due to unspecified IO error.", e);
        }

    }

    private float calculateTotal(List<Item> items) {
        float amount = 0F;
        float shipping = 4.99F;
        amount += items.stream().mapToDouble(i -> i.getQuantity() * i.getUnitPrice()).sum();
        amount += shipping;
        return amount;
    }
}
