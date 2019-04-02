package oracle.ateam.sockshop.orders.domain;


import javax.persistence.*;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

import java.io.Serializable;


import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
public class Cart implements Serializable{

    @NotNull
    @ManyToOne
    private Customer customer;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @OneToMany
    private List<Item> items = new ArrayList<>();

}
