/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micrometer.core.instrument.MeterRegistry;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;
import io.nats.client.Nats;
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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;


@Service
public class MessagingService {
    @Autowired
    private CustomerOrderRepository customerOrderRepository;
    @Autowired
    private MeterRegistry meterRegistry;
    private final Logger log = LoggerFactory.getLogger(getClass());
    private final ObjectMapper objectMapper = new ObjectMapper();
    private Connection nc;
    private final String mushopOrdersSubject;
    private final String mushopShipmentsSubject;
    private final String natsUrl;
    private ExecutorService messageProcessingPool;


    public MessagingService(@Value("nats://${mushop.messaging.host}:${mushop.messaging.port}") String natsUrl,
                            @Value("${mushop.messaging.subjects.orders}") String mushopOrdersSubject,
                            @Value("${mushop.messaging.subjects.shipments}") String mushopShipmentsSubject) throws InterruptedException {
        this.mushopOrdersSubject = mushopOrdersSubject;
        this.mushopShipmentsSubject = mushopShipmentsSubject;
        this.messageProcessingPool = Executors.newCachedThreadPool();
        ExecutorService connectionExecutor = Executors.newSingleThreadExecutor();
        this.natsUrl = natsUrl;
        boolean connected = false;
        while (!connected) {
            try {
                Future<Boolean> result = connectionExecutor.submit(() -> {
                    try {
                        log.info("Connecting to {}", this.natsUrl);
                        nc = Nats.connect(this.natsUrl);
                        Dispatcher d = nc.createDispatcher((msg) -> {
                            handleMessage(msg);
                        });
                        log.info("subscribing to {}", this.mushopShipmentsSubject);
                        d.subscribe(this.mushopShipmentsSubject);
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
        connectionExecutor.shutdown();
        log.info("Connected to NATS {} and subscribed to subject {}", this.natsUrl, this.mushopShipmentsSubject);

    }

    public void dispatchToFulfillment(OrderUpdate order) throws JsonProcessingException {
        log.info("Preparing order for fulfillment {}", order.getOrderId());
        String msg = objectMapper.writeValueAsString(order);
        log.debug("Sending order over to fulfillment {}", order);
        this.nc.publish(this.mushopOrdersSubject, msg.getBytes(StandardCharsets.UTF_8));
        meterRegistry.counter("orders.fulfillment_sent").increment();
    }

    private void handleMessage(Message message) {
        messageProcessingPool.submit(() -> {
            try {
                final OrderUpdate update = objectMapper.readValue(message.getData(), OrderUpdate.class);
                customerOrderRepository.findById(update.getOrderId()).
                        ifPresent((order) -> {
                                    log.debug("Updating order {}", order.getId());
                                    order.setShipment(update.getShipment());
                                    customerOrderRepository.save(order);
                                    log.info("order {} is now {}", order.getId(), update.getShipment().getName());
                                    meterRegistry.counter("orders.fulfillment_ack").increment();

                                }
                        );

            } catch (IOException e) {
                log.error("Failed reading shipping message");
                e.printStackTrace();
            }
        });
    }


}
