package mushop.test.shipping;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import com.oracle.bmc.streaming.model.PutMessagesDetailsEntry;

import mushop.shipping.entities.Shipment;
import mushop.shipping.streams.StreamsPublisher;
import shaded.com.oracle.oci.javasdk.org.apache.commons.lang3.StringUtils;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ShippingApplicationTests {

	@Autowired
	StreamsPublisher publisher;
	
//	@Test
//	public void contextLoads() {
//	}
	
	@Test
	public void testBuildMessageList() {
		String messageTempl = "test buildMessageList";
		
		List<PutMessagesDetailsEntry> messages = publisher.buildMessageList(3, messageTempl);
		
		String msg;
		String id;
		//JSONObject json = null;
		assertTrue(messages.size()==3);
		for (PutMessagesDetailsEntry entry: messages) {
			id = new String(entry.getKey(), UTF_8);
			assertTrue(StringUtils.isNotBlank(id));
			System.out.println(id);
			msg = new String(entry.getValue(), UTF_8);
			assertTrue(StringUtils.isNotBlank(msg));
			try {
				JSONObject json = new JSONObject(msg);
				assertTrue(json.get("id").equals(id));
				String m = (String) json.get("name");
				assertTrue(m.contains(messageTempl));
			} catch (JSONException e) {
				
			}
		}
	}
	
	@Test
	public void testBuildMessageDetailJson() {
		Shipment shipment = new Shipment("test shipment 100");
		JSONObject json = shipment.ToJson();
		
		Method method;
		try {
			method = StreamsPublisher.class.getDeclaredMethod("buildMessageDetailJson", JSONObject.class);
			method.setAccessible(true);
			PutMessagesDetailsEntry msgDetail;
			msgDetail = (PutMessagesDetailsEntry) method.invoke(publisher, json);
			
			assertNotNull(msgDetail);
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	@Test
	public void testAddMessageToList() {
		Shipment shipment = new Shipment("test shipment 100");
		
		Method method;
		try {
			method = StreamsPublisher.class.getDeclaredMethod("addMessageToList", Shipment.class);
			method.setAccessible(true);
			List<PutMessagesDetailsEntry> messages = (List<PutMessagesDetailsEntry>) method.invoke(publisher, shipment);
			
			assertNotNull(messages);
			assertTrue(messages.size()==1);
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
