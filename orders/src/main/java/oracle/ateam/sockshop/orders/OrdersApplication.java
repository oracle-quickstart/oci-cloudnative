package oracle.ateam.sockshop.orders;

import java.util.concurrent.Executors;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.*;

import oracle.ateam.sockshop.orders.services.BootstrapService;


@SpringBootApplication
@RestController
public class OrdersApplication {

	public static void main(String[] args) {
		SpringApplication.run(OrdersApplication.class, args);
	}
	
    @Bean
    public CommandLineRunner commandLineRunner(BootstrapService boot) {
        return args -> {
            Executors.newSingleThreadExecutor().submit(boot::populateData);
        };
    }

}
