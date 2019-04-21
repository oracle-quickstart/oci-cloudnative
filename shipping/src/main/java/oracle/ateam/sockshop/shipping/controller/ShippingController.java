package oracle.ateam.sockshop.shipping.controller;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.oracle.bmc.model.BmcException;
import com.oracle.bmc.streaming.StreamClient;
import com.oracle.bmc.streaming.model.CreateCursorDetails;
import com.oracle.bmc.streaming.model.CreateCursorDetails.Type;
import com.oracle.bmc.streaming.model.PutMessagesDetailsEntry;
import com.oracle.bmc.streaming.requests.CreateCursorRequest;
import com.oracle.bmc.streaming.requests.GetMessagesRequest;
import com.oracle.bmc.streaming.responses.CreateCursorResponse;
import com.oracle.bmc.streaming.responses.GetMessagesResponse;

import oracle.ateam.sockshop.shipping.configuration.OciStreamsConfiguration;
import oracle.ateam.sockshop.shipping.entities.HealthCheck;
import oracle.ateam.sockshop.shipping.entities.Shipment;
import oracle.ateam.sockshop.shipping.streams.StreamsPublisher;

/*
 * MVC Controller for the Shipping application
 */
@RestController
public class ShippingController {

	@Autowired
    OciStreamsConfiguration streamsConfig;
	
	@Autowired
	StreamsPublisher streamsPublisher;
	
	@PostConstruct
	private void initStreamConnection() {
		try {
			streamsConfig.initConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
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
	 * Expects the shipment data in JSON format:
	 * {"id": <any string representing the id>, "name": <any string representing the product name> }
	 * OR
	 * {"name": <any string representing the product name> } in this case the id is auto-generated.
	 */
	@ResponseStatus(HttpStatus.CREATED)
	@PostMapping(path = "/shipping", consumes = "application/json", produces = "application/json")
	@ResponseBody 
	public Shipment postShipping(@RequestBody Shipment shipment) {
		
		System.out.println(shipment.toString());
		streamsPublisher.publishMessage(shipment);
		
		return shipment;
	}
	
	/*
	 * Handles POST request for "/shipping/testbulk"
	 * Expects the shipment data in JSON format:
	 * {"id": <any string representing the id>, "name": <any string representing the product name> }
	 * OR
	 * {"name": <any string representing the product name> } in this case the id is auto-generated.
	 */
	@ResponseStatus(HttpStatus.CREATED)
	@PostMapping(path = "/shipping/testbulk")
	//@ResponseBody 
	public String postTestBulk(@RequestParam(defaultValue="10") String count, @RequestParam(required=false) String message) {
		
		System.out.println(count);
		List<PutMessagesDetailsEntry> messages = streamsPublisher.buildMessageList(Integer.parseInt(count), message);
		streamsPublisher.publishMessages(messages);
		return "published " + count + " messages";
	}
	
	
	/*
	 * Handles GET request for "/health"
	 */
	@ResponseStatus(HttpStatus.OK)
	@GetMapping("/health")
	@ResponseBody
    public Map<String, List<HealthCheck>> getHealth() {
        Map<String, List<HealthCheck>> map = new HashMap<String, List<HealthCheck>>();
        List<HealthCheck> healthChecks = new ArrayList<HealthCheck>();
        Date dateNow = Calendar.getInstance().getTime();

        HealthCheck app = new HealthCheck("shipping", "OK", dateNow);
        HealthCheck streams = new HealthCheck("oci-streams", "OK", dateNow);

        try {
        	StreamClient streamClient = streamsConfig.getStreamClient();
    		String streamId = streamsConfig.getStreamId();
    		
        	CreateCursorDetails cursorDetails =
    				CreateCursorDetails
    				.builder()
    				.partition("0")
    				.type(Type.Latest)
    				.build();
    		
    		CreateCursorRequest createCursorRequest =
    				CreateCursorRequest.builder()
    				.streamId(streamId)
    				.createCursorDetails(cursorDetails)
    				.build();

    		CreateCursorResponse cursorResponse = streamClient.createCursor(createCursorRequest);
    		String cursor = cursorResponse.getCursor().getValue();
    		
    		GetMessagesRequest getRequest =
                    GetMessagesRequest.builder()
                            .streamId(streamId)
                            .cursor(cursor)
                            .limit(1)
                            .build();
    		
    		@SuppressWarnings("unused")
			GetMessagesResponse getResponse = streamClient.getMessages(getRequest);
        } catch ( BmcException e ) {
        	System.out.println("OCI Streams HealthCheck failed: " + e.getCause());
        	streams.setStatus("ERROR");
        }

        healthChecks.add(streams);
        healthChecks.add(app);

        map.put("health", healthChecks);
        return map;
    }
}