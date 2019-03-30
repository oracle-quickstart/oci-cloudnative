package oracle.ateam.sockshop.orders.domain;


import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import javax.persistence.*;

import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
public class Item {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)

    private long id;

    @NotNull(message = "Item Id must not be null")
    private String name;
    private int quantity;
    private float unitPrice;

}
