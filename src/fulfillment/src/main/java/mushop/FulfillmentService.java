package mushop;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micronaut.scheduling.annotation.Scheduled;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;
import io.nats.client.Nats;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Singleton;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Singleton
public class FulfillmentService {
    private Connection nc;
    private final String MUSHOP_ORDERS_SUBJECT = "mushop-orders";
    private final ObjectMapper objectMapper = new ObjectMapper();
    private static final Logger LOG = LoggerFactory.getLogger(FulfillmentService.class);

    public FulfillmentService() {
        try {
            nc = Nats.connect("nats://localhost:4222");
            Dispatcher d = nc.createDispatcher((msg) -> {
                try {
                    handleMessage(msg);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            });
            d.subscribe(MUSHOP_ORDERS_SUBJECT);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Scheduled(fixedDelay = "10s")
    public void publish() throws JsonProcessingException {
        OrderUpdate update = new OrderUpdate("ORD-123", new Shipment("SHP-123", "Processing"));
        String msg = objectMapper.writeValueAsString(update);
        LOG.info("Sending update {}", msg);
        nc.publish(MUSHOP_ORDERS_SUBJECT, msg.getBytes(StandardCharsets.UTF_8));

    }

    private void handleMessage(Message message) throws IOException {
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
        LOG.info("got message {} on the mushop orders subject", update);
    }
}
