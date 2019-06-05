package mushop.stream.controllers;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


/*
 * MVC Controller for the Shipping application
 */
@RestController
public class ConsumerController {

	
	@GetMapping("/hello")
	public String sayHello() {
		DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		Date date = new Date();
		return "Hello " + dateFormat.format(date);
	}
	

}