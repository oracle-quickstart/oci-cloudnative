package mushop.orders.services;

import mushop.orders.config.OrdersConfigurationProperties;
import mushop.orders.controllers.OrdersController;
import mushop.orders.entities.*;
import mushop.orders.repositories.CustomerOrderRepository;
import mushop.orders.resources.NewOrderResource;
import mushop.orders.values.PaymentRequest;
import mushop.orders.values.PaymentResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.core.ParameterizedTypeReference;

import java.io.IOException;
import java.net.URI;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.AdditionalAnswers.returnsFirstArg;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.when;

@SpringBootTest
public class OrderServiceTest {
    @Autowired
    private OrdersService ordersService;

    @Autowired
    private OrdersConfigurationProperties config;

    @MockBean
    private CustomerOrderRepository customerOrderRepository;

    @MockBean
    private AsyncGetService asyncGetService;

    @MockBean
    private MessagingService messagingService;

    @Value(value = "${http.timeout:5}")
    private long timeout;


    NewOrderResource orderPayload = new NewOrderResource(
            URI.create("http://user/customers/1"),
            URI.create("http://user/customers/1/addresses/1"),
            URI.create("http://user/customers/1/cards/1"),
            URI.create("http://carts/carts/1/items"));
    Address address = new Address(
            "001",
            "000",
            "street",
            "city",
            "postcode",
            "country");
    Card card = new Card(
            "001",
            "0000000000000000",
            "00/00",
            "000");
    Customer customer = new Customer(
            "001",
            "firstname",
            "lastName",
            "username",
            Arrays.asList(address),
            Arrays.asList(card));
    List<Item> items = Arrays.asList(new Item("001", "001", 1, 100f));
    PaymentRequest paymentRequest = new PaymentRequest(address, card, customer, 104.99f);
    PaymentResponse payment_authorized = new PaymentResponse(true, "Payment authorized");

    @Test
    public void normalOrdersSucceed() throws IOException, InterruptedException {

        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), paymentRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(payment_authorized));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(items));

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());

        assertThat(ordersService.createNewOrder(orderPayload))
                .isInstanceOf(CustomerOrder.class);

    }

    @Test
    public void highValueOrdersDeclied() throws IOException, InterruptedException {


        List<Item> expensiveItems = Arrays.asList(new Item("001", "001", 1, 200f));
        PaymentRequest priceyRequest = new PaymentRequest(address, card, customer, 204.99f);
        PaymentResponse payment_unauthorized = new PaymentResponse(false, "Payment unauthorized");


        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), priceyRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(payment_unauthorized));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(expensiveItems));

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());


        assertThrows(OrdersController.PaymentDeclinedException.class,
                () -> ordersService.createNewOrder(orderPayload));
    }

    @Test
    public void paymentTimeoutOrdersDeclied() throws IOException, InterruptedException {


        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), paymentRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(null));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(items));

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());


        assertThrows(OrdersController.PaymentDeclinedException.class,
                () -> ordersService.createNewOrder(orderPayload));
    }

    @Test
    public void ioException_rethrown_as_IllegalStateException() throws IOException, InterruptedException {


        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), paymentRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(payment_authorized));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenThrow(new IOException());

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());


        assertThrows(IllegalStateException.class,
                () -> ordersService.createNewOrder(orderPayload));
    }

    @Test
    public void interruptedException_rethrown_as_IllegalStateException() throws IOException, InterruptedException {


        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), paymentRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(payment_authorized));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenThrow(new InterruptedException());

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());


        assertThrows(IllegalStateException.class,
                () -> ordersService.createNewOrder(orderPayload));
    }

    @Test
    public void timeoutException_rethrown_as_IllegalStateException() throws IOException, InterruptedException {


        when(asyncGetService.getObject(orderPayload.address,
                new ParameterizedTypeReference<Address>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(address));

        when(asyncGetService.postResource(config.getPaymentUri(), paymentRequest,
                new ParameterizedTypeReference<PaymentResponse>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(payment_authorized));

        when(asyncGetService.getObject(orderPayload.card,
                new ParameterizedTypeReference<Card>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(card));

        when(asyncGetService.getObject(orderPayload.customer,
                new ParameterizedTypeReference<Customer>() {
                }))
                .thenReturn(CompletableFuture.completedFuture(customer));

        when(asyncGetService.getDataList(orderPayload.items,
                new ParameterizedTypeReference<List<Item>>() {
                }))
                .thenReturn(Executors.newSingleThreadExecutor().submit(
                        () -> {
                            Thread.sleep((timeout * 1000) + 1000);
                            return items;
                        }
                ));

        when(customerOrderRepository.save(any(CustomerOrder.class)))
                .then(returnsFirstArg());

        assertThrows(IllegalStateException.class,
                () -> ordersService.createNewOrder(orderPayload));

    }


}
