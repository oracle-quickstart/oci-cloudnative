/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop;

import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;

@Controller("/fulfillment")
public class FulfillmentController {
    @Get("/{order}")
    public String orderStatus(String order) {
        return "Order " + order + " is fulfilled";
    }
}
