package mushop.orders.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;
import io.nats.client.Nats;
import mushop.orders.entities.CustomerOrder;
import mushop.orders.values.OrderUpdate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Service
public class MessagingService {
    private final Logger LOG = LoggerFactory.getLogger(getClass());
    private final ObjectMapper objectMapper = new ObjectMapper();
    private Connection nc;
    private final String MUSHOP_ORDERS_SUBJECT;
    private final String NATS_URL;

    public MessagingService(@Value("nats://${mushop.orderupdates.host}:${mushop.orderupdates.port}") String NATS_URL,
                            @Value("${mushop.orderupdates.subject}") String MUSHOP_ORDERS_SUBJECT) {
        this.MUSHOP_ORDERS_SUBJECT = MUSHOP_ORDERS_SUBJECT;
        this.NATS_URL = NATS_URL;
        try {
            LOG.info("Connecting to NATS {} and subscribing to subject {}", NATS_URL, MUSHOP_ORDERS_SUBJECT);
            nc = Nats.connect(this.NATS_URL);
            Dispatcher d = nc.createDispatcher((msg) -> {
                try {
                    handleMessage(msg);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            });
            d.subscribe(this.MUSHOP_ORDERS_SUBJECT);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    public void dispatchToFulfillment(CustomerOrder order) throws JsonProcessingException {
        LOG.debug("Preparing order for fulfillment {}", order);
        String msg = objectMapper.writeValueAsString(order);
        LOG.info("Sending order over to fulfillment {}", msg);
    }

    private void handleMessage(Message message) throws IOException {
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
        LOG.info("got message {} on the mushop orders subject", update);
    }


}
