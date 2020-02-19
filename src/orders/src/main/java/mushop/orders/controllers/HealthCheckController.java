/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.controllers;

import mushop.orders.entities.HealthCheck;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
public class HealthCheckController {


    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(method = RequestMethod.GET, path = "/health")
    public
    @ResponseBody
    Map<String, List<HealthCheck>> getHealth() {
      Map<String, List<HealthCheck>> map = new HashMap<String, List<HealthCheck>>();
      List<HealthCheck> healthChecks = new ArrayList<HealthCheck>();
      Date dateNow = Calendar.getInstance().getTime();

      HealthCheck app = new HealthCheck("orders", "OK", dateNow);
      HealthCheck database = new HealthCheck("orders-db", "OK", dateNow);

      

      healthChecks.add(app);
      healthChecks.add(database);

      map.put("health", healthChecks);
      return map;
    }
}
