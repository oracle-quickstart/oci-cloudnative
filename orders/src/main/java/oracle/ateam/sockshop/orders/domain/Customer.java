package oracle.ateam.sockshop.orders.domain;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.*;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private long id;

    private String firstName;
    private String lastName;
    private String username;

    @OneToMany
    private List<Address> addresses = new ArrayList<>();

    @OneToMany
    private List<Card> cards = new ArrayList<>();

}
