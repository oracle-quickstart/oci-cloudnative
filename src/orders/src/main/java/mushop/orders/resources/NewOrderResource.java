/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.resources;

import org.hibernate.validator.constraints.URL;

import java.net.URI;
import java.util.Objects;

public class NewOrderResource {
    @URL
    public URI customer;
    @URL
    public URI address;
    @URL
    public URI card;
    @URL
    public URI items;

    public NewOrderResource() {
    }

    public NewOrderResource(@URL URI customer, @URL URI address, @URL URI card, @URL URI items) {
        this.customer = customer;
        this.address = address;
        this.card = card;
        this.items = items;
    }

    public URI getCustomer() {
        return customer;
    }

    public void setCustomer(URI customer) {
        this.customer = customer;
    }

    public URI getAddress() {
        return address;
    }

    public void setAddress(URI address) {
        this.address = address;
    }

    public URI getCard() {
        return card;
    }

    public void setCard(URI card) {
        this.card = card;
    }

    public URI getItems() {
        return items;
    }

    public void setItems(URI items) {
        this.items = items;
    }

    @Override
    public String toString() {
        return "NewOrderResource{" +
                "\"customer\":" + customer +
                ", \"address\":" + address +
                ", \"card\":" + card +
                ", \"items\": [" + items +
                "] }";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        NewOrderResource that = (NewOrderResource) o;
        return Objects.equals(customer, that.customer) &&
                Objects.equals(address, that.address) &&
                Objects.equals(card, that.card) &&
                Objects.equals(items, that.items);
    }

    @Override
    public int hashCode() {
        return Objects.hash(customer, address, card, items);
    }
}
