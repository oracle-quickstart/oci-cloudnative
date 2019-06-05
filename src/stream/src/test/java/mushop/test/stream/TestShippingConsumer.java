package mushop.test.stream;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import com.oracle.bmc.streaming.StreamClient;
import com.oracle.bmc.streaming.model.CreateCursorDetails;
import com.oracle.bmc.streaming.model.CreateCursorDetails.Type;
import com.oracle.bmc.streaming.model.Message;
import com.oracle.bmc.streaming.model.PutMessagesDetails;
import com.oracle.bmc.streaming.model.PutMessagesDetailsEntry;
import com.oracle.bmc.streaming.model.PutMessagesResultEntry;
import com.oracle.bmc.streaming.requests.CreateCursorRequest;
import com.oracle.bmc.streaming.requests.GetMessagesRequest;
import com.oracle.bmc.streaming.requests.PutMessagesRequest;
import com.oracle.bmc.streaming.responses.CreateCursorResponse;
import com.oracle.bmc.streaming.responses.GetMessagesResponse;
import com.oracle.bmc.streaming.responses.PutMessagesResponse;

import mushop.stream.configuration.OciStreamsConfiguration;
import shaded.com.oracle.oci.javasdk.com.google.common.util.concurrent.Uninterruptibles;

@RunWith(SpringRunner.class)
@SpringBootTest
public class TestShippingConsumer {

	@Autowired
	private OciStreamsConfiguration streamConfig;
   
//	@Autowired
//	private ShippingConsumer shippingConsumer; 

//	@Test
//	public void testConsumeOne() throws Exception {
//		System.out.println(">>> testConsumeOne");
//		assertThat(streamConfig).isNotNull();
//		System.out.println(streamConfig.getStreamId());
//
//		String shipName = "shipment_socks_1";
//		publishMessage(shipName, 1);
//		assertThat(shippingConsumer).isNotNull();
//		shippingConsumer.consumeShippingTopic();
//		//	    	assertThat(shipName, is(equalTo(msg)));
//	}

	@Test
	public void testConsumeOneHundred() throws Exception {
		System.out.println(">>> testConsumeOneHundred");
		assertThat(streamConfig).isNotNull();
		System.out.println(streamConfig.getStreamId());
		

//		publishMessages(buildMessageList(10));
//		assertThat(shippingConsumer).isNotNull();
		//shippingConsumer.consumeShippingTopic();
		//consumeMessage();
		//	    	assertThat(shipName, is(equalTo(msg)));
	}

	/*
	 * Builds a message detail entry with JSON
	 */
	private PutMessagesDetailsEntry buildMessageDetailJson(JSONObject json) {
		
		return PutMessagesDetailsEntry.builder()
		.key( String.valueOf(System.currentTimeMillis()).getBytes(UTF_8) )
		.value( json.toString().getBytes(UTF_8) )
		.build(); 
	}
	
	/*
	 * Builds a message detail entry with String
	 */
	@SuppressWarnings("unused")
	private PutMessagesDetailsEntry buildMessageDetailString(String message) {
		
		return PutMessagesDetailsEntry.builder()
		.key( String.valueOf(System.currentTimeMillis()).getBytes(UTF_8) )
		.value( String.format(message).getBytes(UTF_8) )
		.build(); 
	}
	
	/*
	 * 
	 */
	public List<PutMessagesDetailsEntry>  buildMessageList(int count) {
		List<PutMessagesDetailsEntry> messages = new ArrayList<>();
		
//		String message = "test message ";
//		String msg;
//		for (int i = 0; i < count; i++) {
//			msg = message + " " + i;
//			messages.add(buildMessageDetailString(msg));	
//		}
		
		String message = "test message ";
		String msg;
		for (int i = 0; i < count; i++) {
			msg = message + " " + i;
			JSONObject json = new JSONObject();
			try {
				json.put("id", UUID.randomUUID());
				json.put("name", msg);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			
			messages.add(buildMessageDetailJson(json));	
		}
		return messages;
	}
	
	/*
	 * 
	 */
	public void publishMessages(List<PutMessagesDetailsEntry> messages) {
		
		
		System.out.println("Created list of messages"); 

		System.out.println(
				String.format("Publishing %s messages to stream %s.", messages.size(), streamConfig.getStreamId()));
		PutMessagesDetails messagesDetails =
				PutMessagesDetails.builder().messages(messages).build();

		PutMessagesRequest putRequest =
				PutMessagesRequest.builder()
				.streamId(streamConfig.getStreamId())
				.putMessagesDetails(messagesDetails)
				.build();

		PutMessagesResponse putResponse = streamConfig.getStreamClient().putMessages(putRequest);

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

	/*
	 * 
	 */
	@SuppressWarnings("unused")
	private String consumeMessage() {
		
		StreamClient streamClient = streamConfig.getStreamClient();
		String streamId = streamConfig.getStreamId();
		System.out.println(String.format(">>> streamId: %s", streamId));
		
		String partition = "0";

		CreateCursorDetails cursorDetails =
                CreateCursorDetails.builder()
                        .partition(partition)
                        .type(Type.Latest)
                        //.type(Type.AtOffset)
                        //.type(Type.TrimHorizon)
                        .build();
		
		CreateCursorRequest createCursorRequest =
				CreateCursorRequest.builder()
				.streamId(streamId)
				.createCursorDetails(cursorDetails)
				.build();
		
		CreateCursorResponse cursorResponse = streamClient.createCursor(createCursorRequest);
		String partitionCursor = cursorResponse.getCursor().getValue();
		
		String cursor = partitionCursor;
		for (int i = 0; i < 10; i++) {

			GetMessagesRequest getRequest =
					GetMessagesRequest.builder()
					.streamId(streamId)
					.cursor(cursor)
					.limit(10)
					.build();

			GetMessagesResponse getResponse = streamClient.getMessages(getRequest);

			// process the messages
			System.out.println(String.format("Read %s messages.", getResponse.getItems().size()));
			if ( getResponse.getItems().size() < 1)
				break;
			for (Message message : getResponse.getItems()) {
				//		             	Shipment shipment = new Shipment();
				//		             	handleMessage(Shipment shipment)
				System.out.println(
						String.format(
								"%s: %s",
								new String(message.getKey(), UTF_8),
								new String(message.getValue(), UTF_8)));
			}

			// getMessages is a throttled method; clients should retrieve sufficiently large message
			// batches, as to avoid too many http requests.
			Uninterruptibles.sleepUninterruptibly(1, TimeUnit.SECONDS);

			// use the next-cursor for iteration
			cursor = getResponse.getOpcNextCursor();
		}
			return "";
		} 
    
}
