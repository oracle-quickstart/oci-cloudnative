package mushop;

import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;

@Controller("/fulfillment")
public class FulfillmentController {
    @Get("/{order}")
    public String orderStatus(String order) {
        return "Order " + order + " is fulfilled";
    }
}
