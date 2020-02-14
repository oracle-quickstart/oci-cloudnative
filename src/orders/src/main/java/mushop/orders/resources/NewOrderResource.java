/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.resources;

import org.hibernate.validator.constraints.URL;

import java.net.URI;

public class NewOrderResource {
    @URL
    public URI customer;
    @URL
    public URI address;
    @URL
    public URI card;
    @URL
    public URI items;
}
