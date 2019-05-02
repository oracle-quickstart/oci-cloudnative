package aura.demo.durhamdenim.cart.controllers;

import aura.demo.durhamdenim.cart.entities.HealthCheck;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.orm.hibernate5.HibernateTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;


@RestController
public class HealthCheckController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(method = RequestMethod.GET, path = "/health")
    public
    @ResponseBody
    Map<String, List<HealthCheck>> getHealth() {
       Map<String, List<HealthCheck>> map = new HashMap<String, List<HealthCheck>>();
       List<HealthCheck> healthChecks = new ArrayList<HealthCheck>();
       Date dateNow = Calendar.getInstance().getTime();

       HealthCheck app = new HealthCheck("carts", "OK", dateNow);
       HealthCheck database = new HealthCheck("carts-db", "OK", dateNow);

       try {
          jdbcTemplate.execute("SELECT 1 FROM DUAL;");
       } catch (Exception e) {
          database.setStatus("err");
       }

       healthChecks.add(app);
       healthChecks.add(database);

       map.put("health", healthChecks);
       return map;
    }
}
