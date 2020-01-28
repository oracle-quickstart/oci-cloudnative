package mushop.orders.values;

import mushop.orders.entities.Shipment;

public class OrderUpdate {
    private String orderId;
    private mushop.orders.entities.Shipment Shipment;

    public OrderUpdate() {
    }

    public OrderUpdate(String orderId, Shipment shipment) {
        this.orderId = orderId;
        Shipment = shipment;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public Shipment getShipment() {
        return Shipment;
    }

    public void setShipment(Shipment shipment) {
        Shipment = shipment;
    }

    @Override
    public String toString() {
        return "OrderUpdate{" +
                "orderId='" + orderId + '\'' +
                ", Shipment=" + Shipment +
                '}';
    }
}
