package mushop;

public class OrderUpdate {
    private String orderId;
    private Shipment Shipment;

    public OrderUpdate() {
    }

    public OrderUpdate(String orderId, mushop.Shipment shipment) {
        this.orderId = orderId;
        Shipment = shipment;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public mushop.Shipment getShipment() {
        return Shipment;
    }

    public void setShipment(mushop.Shipment shipment) {
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
