package mushop.cart.controllers;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;
import static org.mockito.Mockito.mock;

import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import mushop.cart.controllers.HealthCheckController;
import mushop.cart.entities.HealthCheck;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration
public class UnitHealthCheckController {

    @Autowired
    private HealthCheckController healthCheckController;

    @Test
    public void shouldGetHealth() {
       Map<String, List<HealthCheck>> results = this.healthCheckController.getHealth();
       assertThat(results.get("health").size(), is(equalTo(2)));
    }

    @Configuration
    static class HealthCheckControllerTestConfiguration {
        @Bean
        public HealthCheckController healthCheckController() {
            return new HealthCheckController();
        }

        @Bean
        public JdbcTemplate mongoTemplate() {
        	JdbcTemplate mongoTemplate = mock(JdbcTemplate.class);
            return mongoTemplate;
        }
    }
}
