package mushop.cart.configuration;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import mushop.cart.cart.CartDAO;
import mushop.cart.entities.Cart;
import mushop.cart.entities.Item;
import mushop.cart.item.ItemDAO;
import mushop.cart.repositories.CartRepository;
import mushop.cart.repositories.ItemRepository;

@Configuration
public class BeanConfiguration {
    @Bean
    @Autowired
    public CartDAO getCartDao(CartRepository cartRepository) {
        return new CartDAO() {
            @Override
            public void delete(Cart cart) {
                cartRepository.delete(cart);
            }

            @Override
            public Cart save(Cart cart) {
                return cartRepository.save(cart);
            }

            @Override
            public List<Cart> findByCustomerId(String customerId) {
                return cartRepository.findByCustomerId(customerId);
            }
        };
    }

    @Bean
    @Autowired
    public ItemDAO getItemDao(ItemRepository itemRepository) {
        return new ItemDAO() {
            @Override
            public Item save(Item item) {
                return itemRepository.save(item);
            }

            @Override
            public void destroy(Item item) {
                itemRepository.delete(item);
            }

            @Override
            public Item findOne(String id) {
                return itemRepository.findById(id).get();
            }
        };
    }
}
