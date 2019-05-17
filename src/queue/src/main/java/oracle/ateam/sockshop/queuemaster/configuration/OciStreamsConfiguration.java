package oracle.ateam.sockshop.queuemaster.configuration;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import com.oracle.bmc.Region;
//import com.google.common.util.concurrent.Uninterruptibles;
import com.oracle.bmc.auth.AuthenticationDetailsProvider;
import com.oracle.bmc.auth.SimpleAuthenticationDetailsProvider;
import com.oracle.bmc.auth.StringPrivateKeySupplier;
import com.oracle.bmc.streaming.StreamAdminClient;
import com.oracle.bmc.streaming.StreamClient;
import com.oracle.bmc.streaming.model.Stream;
import com.oracle.bmc.streaming.model.Stream.LifecycleState;
import com.oracle.bmc.streaming.requests.GetStreamRequest;
import com.oracle.bmc.streaming.requests.ListStreamsRequest;
import com.oracle.bmc.streaming.responses.GetStreamResponse;
import com.oracle.bmc.streaming.responses.ListStreamsResponse;

/* Obtains a connection to OCI Streams
 * 
 */
@Configuration
public class OciStreamsConfiguration {	
	
	@Autowired
	private Environment env;
	
	private StreamClient streamClient = null;
	
	public StreamClient getStreamClient() {
		return streamClient;
	}

	private String streamId = null;
	
	public String getStreamId() {
		return streamId;
	}
	
	/* Constructor that initializes a connection to be used throughout the application.
	 * The connection requires these attributes which are available via environment variables:
	 * TENANT_ID, USER_ID, FINGERPRINT, OCI_API_KEY, REGION AND CONTAINER_ID
	 * If the api key was created with a pass_phrase then the PASS_PHRASE variable is also required.
	 */
	public void initConnection() throws Exception {
		
		final String tenantId = env.getProperty("TENANT_ID");
        final String userId = env.getProperty("USER_ID");
        final String fingerprint = env.getProperty("FINGERPRINT");
        final String privateKey = env.getProperty("OCI_API_KEY");
        //final String passPhrase = env.getProperty("PASS_PHRASE");
        final String region = env.getProperty("REGION");
        
		
        AuthenticationDetailsProvider provider = SimpleAuthenticationDetailsProvider.builder()
            .tenantId(tenantId)
            .userId(userId)
            .fingerprint(fingerprint)
            .privateKeySupplier(new StringPrivateKeySupplier(privateKey))
            .region(Region.fromRegionId(region))
            .build();
        
        // Create an admin-client
        final StreamAdminClient adminClient = new StreamAdminClient(provider);

        final String streamName = "shipping-stream";
        final int partitions = 1;

        Stream stream = getStream(adminClient, env.getProperty("COMPARTMENT_ID"), streamName, partitions);
        
     // Streams are assigned a specific endpoint url based on where they are provisioned.
        // Create a stream client using the provided message endpoint.
        streamClient = new StreamClient(provider);
        streamClient.setEndpoint(stream.getMessagesEndpoint());

        streamId = stream.getId();
        if (null!=streamId) {
        	System.out.println("got streamId: " + streamId);
        }
	}
	
	/*
	 * 
	 */
	private Stream getStream(
            StreamAdminClient adminClient, String compartmentId, String streamName, int partitions)
            throws Exception {

        ListStreamsRequest listRequest =
                ListStreamsRequest.builder()
                        .compartmentId(compartmentId)
                        .lifecycleState(LifecycleState.Active)
                        .name(streamName)
                        .build();

        ListStreamsResponse listResponse = adminClient.listStreams(listRequest);

        if (!listResponse.getItems().isEmpty()) {
            // if we find an active stream with the correct name, we'll use it.
            //System.out.println(String.format("An active stream named %s was found.", streamName));

            String streamId = listResponse.getItems().get(0).getId();
            GetStreamResponse getResponse =
	                adminClient.getStream(GetStreamRequest.builder().streamId(streamId).build());
	        return getResponse.getStream();
        }

        //TODO: should we allow it to create a stream? 
//        System.out.println(
//                String.format("No active stream named %s was found; creating it now.", streamName));
//        Stream createdStream = createStream(adminClient, compartmentId, streamName, partitions);

        // GetStream provides details about a specific stream.
        // Since stream creation is asynchronous; we need to wait for the stream to become active.
//        GetStreamRequest streamRequest =
//                GetStreamRequest.builder().streamId(createdStream.getId()).build();
//        Stream activeStream =
//                adminClient
//                        .getWaiters()
//                        .forStream(streamRequest, LifecycleState.Active)
//                        .execute()
//                        .getStream();

        // Give a little time for the stream to be ready.
//        Uninterruptibles.sleepUninterruptibly(1, TimeUnit.SECONDS);
//        return activeStream;
        return null;
    }
}
