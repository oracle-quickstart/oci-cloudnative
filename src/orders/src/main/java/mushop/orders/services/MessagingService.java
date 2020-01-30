package mushop.orders.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;
import io.nats.client.Nats;
import mushop.orders.entities.CustomerOrder;
import mushop.orders.repositories.CustomerOrderRepository;
import mushop.orders.values.OrderUpdate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@Service
public class MessagingService {
    @Autowired
    private CustomerOrderRepository customerOrderRepository;
    private final Logger LOG = LoggerFactory.getLogger(getClass());
    private final ObjectMapper objectMapper = new ObjectMapper();
    private Connection nc;
    private final String MUSHOP_ORDERS_SUBJECT;
    private final String MUSHOP_SHIPMENTS_SUBJECT;
    private final String NATS_URL;

    public MessagingService(@Value("nats://${mushop.messaging.host}:${mushop.messaging.port}") String NATS_URL,
                            @Value("${mushop.messaging.subjects.orders}") String MUSHOP_ORDERS_SUBJECT,
                            @Value("${mushop.messaging.subjects.shipments}") String MUSHOP_SHIPMENTS_SUBJECT) throws InterruptedException {
        this.MUSHOP_ORDERS_SUBJECT = MUSHOP_ORDERS_SUBJECT;
        this.MUSHOP_SHIPMENTS_SUBJECT = MUSHOP_SHIPMENTS_SUBJECT;
        this.NATS_URL = NATS_URL;
        LOG.info("Connecting to NATS {} and subscribing to subject {}", this.NATS_URL, this.MUSHOP_ORDERS_SUBJECT);
        boolean connected = false;
        while (!connected) {
            try {
                Future<Boolean> result = Executors.newSingleThreadExecutor().submit(() -> {
                    try {
                        nc = Nats.connect(this.NATS_URL);
                        Dispatcher d = nc.createDispatcher((msg) -> {
                            handleMessage(msg);
                        });
                        d.subscribe(this.MUSHOP_SHIPMENTS_SUBJECT);
                        return Boolean.TRUE;
                    } catch (IOException e) {
                        e.printStackTrace();
                        LOG.error("Connection failed due to {}. Retrying in 5s", e.getMessage());
                        Thread.sleep(5000l);
                        return Boolean.FALSE;
                    }
                });
                connected = result.get();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }
        LOG.info("Connected to NATS {} and subscribed to subject {}", this.NATS_URL, this.MUSHOP_ORDERS_SUBJECT);

    }

    public void dispatchToFulfillment(OrderUpdate order) throws JsonProcessingException {
        LOG.info("Preparing order for fulfillment {}", order.getOrderId());
        String msg = objectMapper.writeValueAsString(order);
        LOG.debug("Sending order over to fulfillment {}", order);
        nc.publish(this.MUSHOP_ORDERS_SUBJECT, msg.getBytes(StandardCharsets.UTF_8));
    }

    private void handleMessage(Message message) {
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        try {
            final OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
            customerOrderRepository.findById(update.getOrderId()).
                    ifPresent((order) -> {
                                LOG.debug("Updating order {}", order);
                                order.setShipment(update.getShipment());
                                customerOrderRepository.save(order);
                                LOG.info("order {} is now {}", order.getId(), update.getShipment().getName());
                            }
                    );

        } catch (IOException e) {
            LOG.error("Failed reading shipping message");
            e.printStackTrace();
        }
    }


}
