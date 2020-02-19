/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.values;

import mushop.orders.entities.Shipment;

public class OrderUpdate {
    private Long orderId;
    private mushop.orders.entities.Shipment Shipment;

    public OrderUpdate() {
    }

    public OrderUpdate(Long orderId, Shipment shipment) {
        this.orderId = orderId;
        Shipment = shipment;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
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
