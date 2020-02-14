/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop;

import io.micronaut.core.annotation.TypeHint;
import io.micronaut.runtime.Micronaut;
import io.nats.client.impl.SocketDataPort;

@TypeHint(value = {SocketDataPort.class}, accessType = TypeHint.AccessType.ALL_DECLARED_CONSTRUCTORS)
public class Application {

    public static void main(String[] args) {
        Micronaut.run(Application.class);
    }
}