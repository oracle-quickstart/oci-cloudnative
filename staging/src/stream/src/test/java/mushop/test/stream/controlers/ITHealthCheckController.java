package mushop.test.stream.controlers;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ITHealthCheckController {

    @Autowired
    //private HealthCheckController healthCheckController;

    @Test
    public void getHealthCheck() throws Exception {
//        Map<String, List<HealthCheck>> healthChecks = healthCheckController.getHealth();
//        assertThat(healthChecks.get("health").size(), is(equalTo(2)));
    }
}
