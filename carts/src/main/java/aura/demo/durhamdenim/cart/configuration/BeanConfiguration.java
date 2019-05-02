package aura.demo.durhamdenim.cart.configuration;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import aura.demo.durhamdenim.cart.cart.CartDAO;
import aura.demo.durhamdenim.cart.entities.Cart;
import aura.demo.durhamdenim.cart.entities.Item;
import aura.demo.durhamdenim.cart.item.ItemDAO;
import aura.demo.durhamdenim.cart.repositories.CartRepository;
import aura.demo.durhamdenim.cart.repositories.ItemRepository;

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
