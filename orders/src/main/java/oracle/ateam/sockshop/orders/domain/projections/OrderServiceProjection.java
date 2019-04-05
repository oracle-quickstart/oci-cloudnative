package oracle.ateam.sockshop.orders.domain.projections;

import java.util.Collection;
import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.rest.core.config.Projection;

import oracle.ateam.sockshop.orders.domain.Address;
import oracle.ateam.sockshop.orders.domain.Card;
import oracle.ateam.sockshop.orders.domain.Customer;
import oracle.ateam.sockshop.orders.domain.CustomerOrder;
import oracle.ateam.sockshop.orders.domain.Item;
import oracle.ateam.sockshop.orders.domain.Shipment;

@Projection(name = "OrderProjection", types = {CustomerOrder.class})
public interface OrderServiceProjection {
	
	public Long getId();
	
	public Customer getCustomer();
	
//	@Value("#{target.customer.id}")
//	public Long getCustomerId();
	
	public Address getAddress();
	
	public Card getCard();
	
	public Collection<Item> getItems();
	
	public Shipment getShipment();
	
	public Date getOrderDate();
	
	public float getTotal() ;
	

}
