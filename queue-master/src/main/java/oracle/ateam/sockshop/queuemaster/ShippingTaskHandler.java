package oracle.ateam.sockshop.queuemaster;

import org.springframework.stereotype.Component;

import oracle.ateam.sockshop.shipping.entities.Shipment;

@Component
public class ShippingTaskHandler {

//	@Autowired
//	DockerSpawner docker;

	public void handleMessage(Shipment shipment) {
		System.out.println("Received shipment task: " + shipment.getName());
		//docker.init();
		//docker.spawn();
	}
}
