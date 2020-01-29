package mushop;

public class OrderUpdate {
    private Long orderId;
    private Shipment Shipment;

    public OrderUpdate() {
    }

    public OrderUpdate(Long orderId, mushop.Shipment shipment) {
        this.orderId = orderId;
        Shipment = shipment;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
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
