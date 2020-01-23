package mushop;

import io.micronaut.http.annotation.Get;
import io.micronaut.http.client.annotation.Client;

@Client("/fulfillment")
public interface FulfillmentClient {

    @Get("/{order}")
    String orderStatus(String order);
}
