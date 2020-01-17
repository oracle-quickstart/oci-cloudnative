package mushop.carts;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

public class Cart {

    private String id;

    private String customerId;

    private List<Item> items = new ArrayList<Item>();

    public Cart() {
        id = UUID.randomUUID().toString();
    }

    public Cart(String cartId) {
        this.id = cartId;
    }

    public String getId() {
        return id;
    }

    public String getCustomerId() {
        return customerId;
    }

    public List<Item> getItems() {
        return items;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }

    public boolean removeItem(String itemId) {
        return items.removeIf(item -> itemId.equals(item.getItemId()));
    }

    public void merge(Cart cart) {
        this.customerId = cart.getCustomerId();
        for (Item item : cart.items) {
            mergeItem(item);
        }
    }

    private void mergeItem(Item item) {
        for (Item existing : items) {
            if (existing.getItemId().equals(item.getItemId())) {
                existing.setQuantity(existing.getQuantity() + item.getQuantity());
                return;
            }
        }
        items.add(item);
    }

    @Override
    public String toString() {
        return "Cart [customerId=" + customerId + ", id=" + id + ", items=" + items + "]";
    }

}
