package mushop.orders.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.hateoas.Resource;
import org.springframework.hateoas.mvc.TypeReferences;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import mushop.orders.config.OrdersConfigurationProperties;
import mushop.orders.entities.Address;
import mushop.orders.entities.Card;
import mushop.orders.entities.Customer;
import mushop.orders.entities.CustomerOrder;
import mushop.orders.entities.Item;
import mushop.orders.entities.Shipment;
import mushop.orders.repositories.CustomerOrderRepository;
import mushop.orders.resources.NewOrderResource;
import mushop.orders.services.AsyncGetService;
import mushop.orders.values.PaymentRequest;
import mushop.orders.values.PaymentResponse;

import java.io.IOException;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


@RepositoryRestController
public class OrdersController {
    private final Logger LOG = LoggerFactory.getLogger(getClass());

    @Autowired
    private OrdersConfigurationProperties config;

    @Autowired
    private AsyncGetService asyncGetService;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @Value(value = "${http.timeout:5}")
    private long timeout;

    @ResponseStatus(HttpStatus.CREATED)
    @RequestMapping(path = "/orders", consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.POST)
    public
    @ResponseBody
    CustomerOrder newOrder(@RequestBody NewOrderResource item) {
        try {

            if (item.address == null || item.customer == null || item.card == null || item.items == null) {
                throw new InvalidOrderException("Invalid order request. Order requires customer, address, card and items.");
            }


            LOG.debug("Starting calls");
            Future<Address> addressFuture = asyncGetService.getObject(item.address, new ParameterizedTypeReference<Address>() {
            });
            Future<Customer> customerFuture = asyncGetService.getObject(item.customer, new ParameterizedTypeReference<Customer>() {
            });
            Future<Card> cardFuture = asyncGetService.getObject(item.card, new ParameterizedTypeReference<Card>() {
            });
            Future<List<Item>> itemsFuture = asyncGetService.getDataList(item.items, new
                    ParameterizedTypeReference<List<Item>>() {
            });
//            Future<Customer> custFut = asyncGetService.getCustomer(item.customer);
//            Customer cust = custFut.get(timeout, TimeUnit.SECONDS);
//            LOG.debug("Customer : "+cust);
            LOG.debug("End of calls.");

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
                throw new PaymentDeclinedException("Unable to parse authorisation packet");
            }
            if (!paymentResponse.isAuthorised()) {
                throw new PaymentDeclinedException(paymentResponse.getMessage());
            }

            // Ship
            String customerId = parseId(customerFuture.get(timeout, TimeUnit.SECONDS).getId());
            Future<Shipment> shipmentFuture = asyncGetService.postResource(config.getShippingUri(), new Shipment
                    (customerId), new ParameterizedTypeReference<Shipment>() {
            });

            CustomerOrder order = new CustomerOrder(
                    null,
                    customerFuture.get(timeout, TimeUnit.SECONDS),
                    addressFuture.get(timeout, TimeUnit.SECONDS),
                    cardFuture.get(timeout, TimeUnit.SECONDS),
                    itemsFuture.get(timeout, TimeUnit.SECONDS),
                    shipmentFuture.get(timeout, TimeUnit.SECONDS),
                    Calendar.getInstance().getTime(),
                    amount);
            LOG.debug("Received data: " + order.toString());

            CustomerOrder savedOrder = customerOrderRepository.save(order);
            LOG.debug("Saved order: " + savedOrder);

            return savedOrder;
        } catch (TimeoutException e) {
            throw new IllegalStateException("Unable to create order due to timeout from one of the services.", e);
        } catch (InterruptedException | IOException | ExecutionException e) {
            throw new IllegalStateException("Unable to create order due to unspecified IO error.", e);
        }
    }

    private String parseId(String href) {
        Pattern idPattern = Pattern.compile("[\\w-]+$");
        Matcher matcher = idPattern.matcher(href);
        if (!matcher.find()) {
            throw new IllegalStateException("Could not parse user ID from: " + href);
        }
        return matcher.group(0);
    }

//    TODO: Add link to shipping
//    @RequestMapping(method = RequestMethod.GET, value = "/orders")
//    public @ResponseBody
//    ResponseEntity<?> getOrders() {
//        List<CustomerOrder> customerOrders = customerOrderRepository.findAll();
//
//        Resources<CustomerOrder> resources = new Resources<>(customerOrders);
//
//        resources.forEach(r -> r);
//
//        resources.add(linkTo(methodOn(ShippingController.class, CustomerOrder.getShipment::ge)).withSelfRel());
//
//        // add other links as needed
//
//        return ResponseEntity.ok(resources);
//    }

    private float calculateTotal(List<Item> items) {
        float amount = 0F;
        float shipping = 4.99F;
        amount += items.stream().mapToDouble(i -> i.getQuantity() * i.getUnitPrice()).sum();
        amount += shipping;
        return amount;
    }

    @ResponseStatus(value = HttpStatus.NOT_ACCEPTABLE)
    public class PaymentDeclinedException extends IllegalStateException {
        public PaymentDeclinedException(String s) {
            super(s);
        }
    }

    @ResponseStatus(value = HttpStatus.NOT_ACCEPTABLE)
    public class InvalidOrderException extends IllegalStateException {
        public InvalidOrderException(String s) {
            super(s);
        }
    }
}
