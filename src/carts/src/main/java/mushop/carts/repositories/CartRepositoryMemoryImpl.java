package mushop.carts.repositories;

import io.micronaut.context.annotation.Secondary;
import mushop.carts.entitites.Cart;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Singleton;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Implements the CartRepository in-memory.
 */
@Singleton
@Secondary
public class CartRepositoryMemoryImpl implements CartRepository {

    public static final Logger LOG = LoggerFactory.getLogger(CartRepositoryMemoryImpl.class);

    private final List<Cart> carts;

    public CartRepositoryMemoryImpl() {
        LOG.info("Using in-memory repository.");
        this.carts = new ArrayList<Cart>();
    }

    @Override
    public void save(Cart cart) {
        for (int i = 0; i < carts.size(); i++) {
            if (carts.get(i).getId().equals(cart.getId())) {
                carts.set(i, cart);
                return;
            }
        }
        carts.add(cart);
    }

    @Override
    public Cart getById(String id) {
        for (Cart c : carts) {
            if (c.getId().equals(id)) {
                return c;
            }
        }
        return null;
    }

    @Override
    public boolean deleteCart(String id) {
        Iterator<Cart> iter = carts.iterator();
        while (iter.hasNext()) {
            Cart c = iter.next();
            if (c.getId().equals(id)) {
                iter.remove();
                return true;
            }
        }
        return false;
    }

    @Override
    public List<Cart> getByCustomerId(String custId) {
        List<Cart> result = new ArrayList<Cart>();
        for (Cart c : carts) {
            if (c.getCustomerId().equals(custId)) {
                result.add(c);
            }
        }
        return result;
    }

    @Override
    public boolean healthCheck() {
        return true;
    }

}
