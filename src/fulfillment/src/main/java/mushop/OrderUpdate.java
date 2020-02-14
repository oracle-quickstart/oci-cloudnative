/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop;

import io.micronaut.core.annotation.Introspected;

@Introspected
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
