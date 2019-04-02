package oracle.ateam.sockshop.orders.domain;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.*;

import org.springframework.data.annotation.CreatedDate;


import javax.annotation.Generated;
import javax.persistence.*;
import java.io.Serializable;


import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.List;

// curl -XPOST -H 'Content-type: application/json' http://localhost:8082/orders -d '{"customer":
// "http://localhost:8080/customer/1", "address": "http://localhost:8080/address/1", "card":
// "http://localhost:8080/card/1", "items": "http://localhost:8081/carts/1/items"}'

// curl http://localhost:8082/orders/search/customerId\?custId\=1

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerOrder implements Serializable{

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @OneToOne(cascade = CascadeType.ALL)
    private Customer customer;

    @OneToOne(cascade = CascadeType.ALL)
    private Address address;

    @OneToOne(cascade = CascadeType.ALL)
    private Card card;

    @OneToMany(cascade = CascadeType.ALL)
    private Collection<Item> items;

    @OneToOne(cascade = CascadeType.ALL)
    private Shipment shipment;

    @Column(nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreatedDate
    private Date orderDate = Calendar.getInstance().getTime();

    private float total;

    
}
