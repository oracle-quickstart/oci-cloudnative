package oracle.ateam.sockshop.orders.services.impl;

import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import oracle.ateam.sockshop.orders.domain.Address;
import oracle.ateam.sockshop.orders.domain.Card;
import oracle.ateam.sockshop.orders.domain.Customer;
import oracle.ateam.sockshop.orders.domain.CustomerOrder;
import oracle.ateam.sockshop.orders.domain.Item;
import oracle.ateam.sockshop.orders.repo.CustomerOrderRepository;
import oracle.ateam.sockshop.orders.services.BootstrapService;

@Service
public class BootstrapServiceImpl implements BootstrapService{
	
	@Autowired
	CustomerOrderRepository orderrepo;

	@Override
	public void populateData() {
		Address myAddress = new Address();
		myAddress.setStreet_number("300");
		myAddress.setStreet("Iron Horse Parkway");
		myAddress.setCity("Dublin");
		myAddress.setCountry("USA");
		myAddress.setPostcode("5000");
		
		Item item = new Item();
		item.setName("Gateron Switches");
		item.setQuantity(20);
		item.setUnitPrice(15.5f);
		ArrayList items = new ArrayList<Item>();
		items.add(item);
		
		Card myCard = new Card();
		myCard.setCcv("999");
		myCard.setExpires("08/2020");
		myCard.setLongNum("0000-1111-2222-3333");
		
		Customer me = new Customer();
		me.setFirstName("john");
		me.setLastName("Doe");
		me.setUsername("koffi");
		
		CustomerOrder order = new CustomerOrder();
		order.setAddress(myAddress);
		order.setCard(myCard);
		order.setCustomer(me);
		order.setTotal(5000);
		order.setItems(items);
		
		orderrepo.save(order);
	}

}
