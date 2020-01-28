package mushop.orders.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import mushop.orders.entities.CustomerOrder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class MessagingService {
    private final Logger LOG = LoggerFactory.getLogger(getClass());
    private final ObjectMapper objectMapper = new ObjectMapper();


    public void dispatchToFulfillment(CustomerOrder order) throws JsonProcessingException {
        LOG.debug("Preparing order for fulfillment {}", order);
        String msg = objectMapper.writeValueAsString(order);
        LOG.info("Sending order over to fulfillment {}", msg);
    }


}
