package aura.demo.durhamdenim.cart.cart;

import aura.demo.durhamdenim.cart.entities.Item;

import java.util.List;
import java.util.function.Supplier;


public interface Contents<T> {
    Supplier<List<T>> contents();

    Runnable add(Supplier<Item> item);

    Runnable delete(Supplier<Item> item);
}
