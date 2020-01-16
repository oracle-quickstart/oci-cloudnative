package mushop.carts;

import java.math.BigDecimal;
import java.util.UUID;

public class Item {

    private String id;

    private String itemId;

    private int quantity;

    private BigDecimal unitPrice;

    public Item() {
        this.id = UUID.randomUUID().toString();
        this.quantity = 1;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((itemId == null) ? 0 : itemId.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        Item other = (Item) obj;
        if (itemId == null) {
            if (other.itemId != null) {
                return false;
            }
        } else if (!itemId.equals(other.itemId)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Item [id=" + id + ", itemId=" + itemId + ", quantity=" + quantity + ", unitPrice=" + unitPrice + "]";
    }

}
