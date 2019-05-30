package mushop.queuemaster;

import org.springframework.stereotype.Component;

import mushop.shipping.entities.Shipment;

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
