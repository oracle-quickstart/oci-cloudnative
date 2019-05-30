package mushop.queuemaster.controllers;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.oracle.bmc.model.BmcException;
import com.oracle.bmc.streaming.StreamClient;
import com.oracle.bmc.streaming.model.CreateCursorDetails;
import com.oracle.bmc.streaming.model.CreateCursorDetails.Type;
import com.oracle.bmc.streaming.requests.CreateCursorRequest;
import com.oracle.bmc.streaming.requests.GetMessagesRequest;
import com.oracle.bmc.streaming.responses.CreateCursorResponse;
import com.oracle.bmc.streaming.responses.GetMessagesResponse;

import mushop.queuemaster.configuration.OciStreamsConfiguration;
import mushop.queuemaster.entities.HealthCheck;

@RestController
public class HealthCheckController {

	@Autowired
    OciStreamsConfiguration streamsConfig;

    @ResponseStatus(HttpStatus.OK)
    @GetMapping("/health")
    @ResponseBody
    public Map<String, List<HealthCheck>> getHealth() {
        Map<String, List<HealthCheck>> map = new HashMap<String, List<HealthCheck>>();
        List<HealthCheck> healthChecks = new ArrayList<HealthCheck>();
        Date dateNow = Calendar.getInstance().getTime();

        HealthCheck app = new HealthCheck("queue-master", "OK", dateNow);
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

        healthChecks.add(app);
        healthChecks.add(streams);

        map.put("health", healthChecks);
        return map;
    }
}
