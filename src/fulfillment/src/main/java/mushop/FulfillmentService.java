/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micrometer.core.instrument.MeterRegistry;
import io.micronaut.context.annotation.Value;
import io.micronaut.core.annotation.Introspected;
import io.micronaut.discovery.event.ServiceReadyEvent;
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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@Singleton
@Introspected
public class FulfillmentService {
    private Connection nc;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private static final Logger log = LoggerFactory.getLogger(FulfillmentService.class);
    @Value("nats://${mushop.messaging.host}:${mushop.messaging.port}")
    private String natsUrl;
    @Value("${mushop.messaging.subjects.orders}")
    private String mushopOrdersSubject;
    @Value("${mushop.messaging.subjects.shipments}")
    private String mushopShipmentsSubject;
    @Value("${mushop.messaging.simulation-delay}")
    private Long simulationDelay;
    private ExecutorService messageProcessingPool;
    private MeterRegistry meterRegistry;

    public FulfillmentService(MeterRegistry meterRegistry) {
        messageProcessingPool = Executors.newCachedThreadPool();
        this.meterRegistry = meterRegistry;
    }

    @EventListener
    @Async
    public void connect(final ServiceReadyEvent event) throws InterruptedException {
        boolean connected = false;
        ExecutorService connect = Executors.newSingleThreadExecutor();
        while (!connected) {
            try {
                Future<Boolean> result = connect.submit(() -> {
                    try {
                        log.info("Connecting to {}", this.natsUrl);
                        nc = Nats.connect(this.natsUrl);
                        Dispatcher d = nc.createDispatcher((msg) -> {
                            try {
                                OrderUpdate update = handleMessage(msg);
                                meterRegistry.counter("orders.received","app","fulfillment").increment();
                                fulfillOrder(update);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        });
                        log.info("subscribing to {}", this.mushopOrdersSubject);
                        d.subscribe(this.mushopOrdersSubject);
                        return Boolean.TRUE;
                    } catch (IOException e) {
                        e.printStackTrace();
                        log.error("Connection failed due to {}. Retrying in 5s", e.getMessage());
                        Thread.sleep(5000l);
                        return Boolean.FALSE;
                    }
                });
                connected = result.get();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }
        connect.shutdown();
        log.info("Connected to NATS {} and subscribed to subject {}", this.natsUrl, this.mushopOrdersSubject);

    }

    private OrderUpdate handleMessage(Message message) throws IOException {
        String response = new String(message.getData(), StandardCharsets.UTF_8);
        OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
        log.info("got message {} on the mushop orders subject", update);
        return update;
    }

    private void fulfillOrder(OrderUpdate order) {
        messageProcessingPool.submit(() -> {
            try {
                Thread.sleep(simulationDelay);
                Shipment shipment = new Shipment(UUID.randomUUID().toString(), "Shipped");
                order.setShipment(shipment);
                String msg = objectMapper.writeValueAsString(order);
                log.info("Sending shipment update {}", msg);
                nc.publish(mushopShipmentsSubject, msg.getBytes(StandardCharsets.UTF_8));
                meterRegistry.counter("orders.fulfilled","app","fulfillment").increment();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (JsonProcessingException e) {
                e.printStackTrace();
            }
        });
    }
}
