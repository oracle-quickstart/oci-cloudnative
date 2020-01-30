package mushop;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micronaut.context.annotation.Value;
import io.micronaut.core.annotation.Introspected;
import io.micronaut.discovery.event.ServiceStartedEvent;
import io.micronaut.runtime.event.annotation.EventListener;
import io.micronaut.scheduling.annotation.Async;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;
import io.nats.client.Nats;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Singleton;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@Singleton
@Introspected
public class FulfillmentService {
    private Connection nc;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private static final Logger LOG = LoggerFactory.getLogger(FulfillmentService.class);
    @Value("nats://${mushop.messaging.host}:${mushop.messaging.port}")
    private String NATS_URL;
    @Value("${mushop.messaging.subjects.orders}")
    private String MUSHOP_ORDERS_SUBJECT;
    @Value("${mushop.messaging.subjects.shipments}")
    private String MUSHOP_SHIPMENTS_SUBJECT;
    @Value("${mushop.messaging.simulation-delay}")
    private Long simulationDelay;

    public FulfillmentService() {
    }

    @EventListener
    @Async
    public void connect(final ServiceStartedEvent event) throws InterruptedException {
        LOG.info("Connecting to NATS {} and subscribing to subject {}", this.NATS_URL, this.MUSHOP_ORDERS_SUBJECT);
        boolean connected = false;
        while (!connected) {
            try {
                Future<Boolean> result = Executors.newSingleThreadExecutor().submit(() -> {
                    try {
                        nc = Nats.connect(this.NATS_URL);
                        Dispatcher d = nc.createDispatcher((msg) -> {
                            try {
                                handleMessage(msg);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        });
                        d.subscribe(this.MUSHOP_ORDERS_SUBJECT);
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

    private void handleMessage(Message message) throws IOException {
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
        LOG.info("got message {} on the mushop orders subject", update);
        fulfillOrder(update);
    }

    private void fulfillOrder(OrderUpdate order) {
        Executors.newSingleThreadExecutor().submit(() -> {
            try {
                Thread.sleep(simulationDelay);
                Shipment shipment = new Shipment(UUID.randomUUID().toString(), "Shipped");
                order.setShipment(shipment);
                String msg = objectMapper.writeValueAsString(order);
                LOG.info("Sending shipment update {}", msg);
                nc.publish(MUSHOP_SHIPMENTS_SUBJECT, msg.getBytes(StandardCharsets.UTF_8));
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            }
        });
    }
}
