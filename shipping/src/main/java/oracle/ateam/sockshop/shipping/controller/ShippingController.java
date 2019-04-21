package oracle.ateam.shipping.controller;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.oracle.bmc.streaming.StreamClient;

import oracle.ateam.shipping.configuration.OciStreamsConfiguration;
import oracle.ateam.shipping.entities.HealthCheck;
import oracle.ateam.shipping.entities.Shipment;
import oracle.ateam.shipping.streams.StreamsManager;

/*
 * MVC Controller for the Shipping application
 */
@RestController
public class ShippingController {

	@Autowired
    OciStreamsConfiguration streamsConfig;
	
	@Autowired
	StreamsManager streamsManager;
	
	private String streamId = null;
	private StreamClient streamClient = null;
	
	@PostConstruct
	private void initStreamConnection() {
		try {
			streamsConfig.initConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		streamClient = streamsConfig.getStreamClient();
		streamId = streamsConfig.getStreamId();
	}
	
	/*
	 * Handles GET request for "/shipping"
	 */
	@GetMapping("/shipping")
	public String getShipping() {
		//TODO: get shipments from streams
		return "GET ALL Shipping Resource.";
	}
	
	/*
	 * Handles GET request for "/shipping/id"
	 */
	@GetMapping("/shipping/{id}")
    public String getShippingById(@PathVariable String id) {
		//TODO: get shipment from streams
        return "GET Shipping Resource with id: " + id;
    }
	
	/*
	 * Handles POST request for "/shipping"
	 */
	@ResponseStatus(HttpStatus.CREATED)
	@PostMapping(path = "/shipping", consumes = "application/json", produces = "application/json")
	public 
	@ResponseBody 
	Shipment postShipping(@RequestBody Shipment shipment) {
		//add shipment to streams
		streamsManager.publishMessage(shipment.getName());
		
		System.out.println("added shipment to streams");
		System.out.println(shipment.toString());
		return shipment;
	}
	
	/*
	 * Handles GET request for "/health"
	 */
	@ResponseStatus(HttpStatus.OK)
	@GetMapping("/health")
    public
    @ResponseBody
    Map<String, List<HealthCheck>> getHealth() {
        Map<String, List<HealthCheck>> map = new HashMap<String, List<HealthCheck>>();
        List<HealthCheck> healthChecks = new ArrayList<HealthCheck>();
        Date dateNow = Calendar.getInstance().getTime();

        //TODO: get health of streams
//        HealthCheck rabbitmq = new HealthCheck("shipping-rabbitmq", "OK", dateNow);
        HealthCheck app = new HealthCheck("shipping", "OK", dateNow);

//        try {
//            this.rabbitTemplate.execute(new ChannelCallback<String>() {
//                @Override
//                public String doInRabbit(Channel channel) throws Exception {
//                    Map<String, Object> serverProperties = channel.getConnection().getServerProperties();
//                    return serverProperties.get("version").toString();
//                }
//            });
//        } catch ( AmqpException e ) {
//            rabbitmq.setStatus("err");
//        }

//        healthChecks.add(rabbitmq);
        healthChecks.add(app);

        map.put("health", healthChecks);
        return map;
    }
}