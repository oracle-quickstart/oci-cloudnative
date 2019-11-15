package mushop.cart.item;

import java.util.HashMap;
import java.util.Map;

import mushop.cart.entities.Item;

public interface ItemDAO {
    Item save(Item item);

    void destroy(Item item);

    Item findOne(String id);

    class Fake implements ItemDAO {
        private Map<String, Item> store = new HashMap<>();

        @Override
        public Item save(Item item) {
            return store.put(item.itemId(), item);
        }

        @Override
        public void destroy(Item item) {
            store.remove(item.itemId());

        }

        @Override
        public Item findOne(String id) {
            return store.entrySet().stream().filter(i -> i.getValue().id().equals(id)).map(Map.Entry::getValue)
                    .findFirst().orElse(null);
        }
    }
}
