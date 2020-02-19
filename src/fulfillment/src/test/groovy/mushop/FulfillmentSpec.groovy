/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop

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
