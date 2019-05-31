package mushop.cart.cart;

import java.util.List;
import java.util.function.Supplier;

import mushop.cart.entities.Item;


public interface Contents<T> {
    Supplier<List<T>> contents();

    Runnable add(Supplier<Item> item);

    Runnable delete(Supplier<Item> item);
}
