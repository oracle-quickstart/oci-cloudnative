package mushop.carts;

import java.util.List;

/**
 * An interface to a collection of shopping carts (Cart objects).
 */
public interface CartRepository {

    /**
     * Adds or updates a Cart in the collection. If a cart with the given id already
     * exists, it is replaced. Otherwise, the cart is added.
     */
    void save(Cart cart);

    /**
     * Gets the cart with the specified cart id 
     */
    Cart getById(String id);

    /**
     * Deletes the cart with the specified cart id
     */
    boolean deleteCart(String id);

    /** 
     * Selects carts that have the same customer id
     */
    List<Cart> getByCustomerId(String custId);

    /**
     * Check the connection to the database
     * @return boolean true if connected to a database, false if not. 
     */
    boolean healthCheck();
    
}

