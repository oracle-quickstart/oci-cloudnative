package oracle.ateam.shipping.streams;

import static java.nio.charset.StandardCharsets.UTF_8;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import com.oracle.bmc.streaming.model.PutMessagesDetails;
import com.oracle.bmc.streaming.model.PutMessagesDetailsEntry;
import com.oracle.bmc.streaming.model.PutMessagesResultEntry;
import com.oracle.bmc.streaming.requests.PutMessagesRequest;
import com.oracle.bmc.streaming.responses.PutMessagesResponse;

import oracle.ateam.shipping.configuration.OciStreamsConfiguration;

@Configuration
public class StreamsManager {
	
	@Autowired
    OciStreamsConfiguration streamsConfig;

	
	/*
	 * 
	 */
	public void publishMessage(String msg) {
		List<PutMessagesDetailsEntry> messages = new ArrayList<>();
		messages.add(
			PutMessagesDetailsEntry.builder()
			.key( String.valueOf(System.currentTimeMillis()).getBytes(UTF_8) )
			.value( String.format(msg).getBytes(UTF_8) )
			.build() 
		);
		System.out.println("Created list of messages"); 
		publishToStreams(messages);
	}
	 
	 /*
	  * 
	  */
	 private void publishToStreams(List<PutMessagesDetailsEntry> messages) {

		 
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
