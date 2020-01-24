package mushop;

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
    private Connection nc ;
    private final String MUSHOP_ORDERS_SUBJECT = "mushop-orders";
    private static final Logger LOG = LoggerFactory.getLogger(FulfillmentService.class);

    public FulfillmentService() {
        try {
            nc = Nats.connect("nats://localhost:4222");
            Dispatcher d = nc.createDispatcher((msg) -> {
                handleMessage(msg);
            });
            d.subscribe(MUSHOP_ORDERS_SUBJECT);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Scheduled(fixedDelay = "10s")
    public void publish(){
        nc.publish(MUSHOP_ORDERS_SUBJECT, "Test Order".getBytes(StandardCharsets.UTF_8));
    }

    private void handleMessage(Message message){
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        LOG.info("got message {} on the mushop orders subject", message);
    }
}
