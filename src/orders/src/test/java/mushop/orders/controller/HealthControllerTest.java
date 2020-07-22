package mushop.orders.controller;

import mushop.orders.controllers.HealthCheckController;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(HealthCheckController.class)
public class HealthControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    void getHealth_returns200() throws Exception {

        this.mockMvc.perform(get("/health"))
                .andExpect(status().isOk());
    }
}
