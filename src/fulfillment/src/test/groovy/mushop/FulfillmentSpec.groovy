package mushop

import io.micronaut.context.ApplicationContext
import io.micronaut.runtime.server.EmbeddedServer
import spock.lang.AutoCleanup
import spock.lang.Shared
import spock.lang.Specification

class FulfillmentSpec extends Specification{

    @Shared @AutoCleanup
    EmbeddedServer server = ApplicationContext.run(EmbeddedServer)

    FulfillmentClient client = server.applicationContext.getBean(FulfillmentClient);

    void 'test Fulfillment Controller'(){
        expect:
            client.orderStatus("123").equals("Order 123 is fulfilled")
    }
}
