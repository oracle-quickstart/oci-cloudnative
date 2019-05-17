package aura.demo.durhamdenim.cart;

import aura.demo.durhamdenim.cart.entities.Cart;
import aura.demo.durhamdenim.cart.repositories.CartRepository;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.List;

import static org.junit.Assert.assertEquals;

@RunWith(SpringRunner.class)
@EnableAutoConfiguration
public class ITCartRepository {
    @Autowired
    private CartRepository cartRepository;

    @Before
    public void removeAllData() {
        cartRepository.deleteAll();
    }

    @Test
    public void testCartSave() {
        Cart original = new Cart("customerId");
        Cart saved = cartRepository.save(original);

        assertEquals(1, cartRepository.count());
        assertEquals(original, saved);
    }

    @Test
    public void testCartGetDefault() {
        Cart original = new Cart("customerId");
        Cart saved = cartRepository.save(original);

        assertEquals(1, cartRepository.count());
        assertEquals(original, saved);
    }

    @Test
    public void testSearchCustomerById() {
        Cart original = new Cart("customerId");
        cartRepository.save(original);

        List<Cart> found = cartRepository.findByCustomerId(original.customerId);
        assertEquals(1, found.size());
        assertEquals(original, found.get(0));
    }
}
