package mushop.shipping.streams;

import static java.nio.charset.StandardCharsets.UTF_8;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import com.oracle.bmc.streaming.model.PutMessagesDetails;
import com.oracle.bmc.streaming.model.PutMessagesDetailsEntry;
import com.oracle.bmc.streaming.model.PutMessagesResultEntry;
import com.oracle.bmc.streaming.requests.PutMessagesRequest;
import com.oracle.bmc.streaming.responses.PutMessagesResponse;

import mushop.shipping.configuration.OciStreamsConfiguration;
import mushop.shipping.entities.Shipment;

@Configuration
public class StreamsPublisher {
	
	@Autowired
    OciStreamsConfiguration streamsConfig;
	

	/*
	 * 
	 */
	public List<PutMessagesDetailsEntry>  buildMessageList(int count, String message) {
		List<PutMessagesDetailsEntry> messages = new ArrayList<>();
		
		if (message==null) {
			message = "test message ";
		}
		for (int i = 0; i < count; i++) {
			JSONObject json = new JSONObject();
			try {
				json.put("id", UUID.randomUUID().toString());
				json.put("name", message + " " + i);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			
			messages.add(buildMessageDetailJson(json));	
		}
		return messages;
	}
	
	/*
	 * Builds a message detail entry with JSON
	 */
	private PutMessagesDetailsEntry buildMessageDetailJson(JSONObject json) {
		
		// Use the line below for Strings
		//.value( String.format(message).getBytes(UTF_8) )
		
		return PutMessagesDetailsEntry.builder()
		.key( json.get("id").toString().getBytes(UTF_8) )
		.value( json.toString().getBytes(UTF_8) )
		.build(); 
	}
	
	/*
	 * 
	 */
	private List<PutMessagesDetailsEntry> addMessageToList(Shipment shipment) {
		
		List<PutMessagesDetailsEntry> messages = new ArrayList<>();
		messages.add(buildMessageDetailJson(shipment.ToJson()));
		System.out.println("Created list of with one message"); 
		return messages;
	}
	
	/*
	  * 
	  */
	 public void publishMessage(Shipment shipment) {

		 List<PutMessagesDetailsEntry> messages = addMessageToList(shipment);
		 publishMessages(messages);
	 }
	 
	 /*
	  * 
	  */
	 public void publishMessages(List<PutMessagesDetailsEntry> messages) {

		 
		 System.out.println(
				 String.format("Publishing %s messages to stream %s.", messages.size(), streamsConfig.getStreamId()));
		 
		 PutMessagesDetails messagesDetails =
				 PutMessagesDetails.builder().messages(messages).build();

		 PutMessagesRequest putRequest =
				 PutMessagesRequest.builder()
				 .streamId(streamsConfig.getStreamId())
				 .putMessagesDetails(messagesDetails)
				 .build();

		 PutMessagesResponse putResponse = streamsConfig.getStreamClient().putMessages(putRequest);

		 // the putResponse can contain some useful metadata for handling failures
		 for (PutMessagesResultEntry entry : putResponse.getPutMessagesResult().getEntries()) {
			 if (StringUtils.isNotBlank(entry.getError())) {
				 System.out.println(
						 String.format("Error(%s): %s", entry.getError(), entry.getErrorMessage()));
			 } else {
				 System.out.println(
						 String.format(
								 "Published message to partition %s, offset %s.",
								 entry.getPartition(),
								 entry.getOffset()));
			 }
		 }
	 }
}
