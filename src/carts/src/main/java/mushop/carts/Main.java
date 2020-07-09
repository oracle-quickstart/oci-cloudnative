package mushop.carts;

import io.helidon.config.Config;
import io.helidon.health.HealthSupport;
import io.helidon.health.checks.HealthChecks;
import io.helidon.media.jsonb.JsonbSupport;
import io.helidon.metrics.MetricsSupport;
import io.helidon.webserver.Routing;
import io.helidon.webserver.WebServer;
import io.helidon.webserver.accesslog.AccessLogSupport;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;

public class Main {
        
    private Main() {
        // singleton
    }
    
    public static void main(String[] args) {
        WebServer server = createWebServer();
        server.start().thenAccept(ws -> {
            System.out.println("Running on port " + ws.port());
            ws.whenShutdown().thenRun(() -> System.out.println("Server stopped."));
        }).exceptionally(t -> {
            System.err.println("Startup failed: " + t.getMessage());
            t.printStackTrace(System.err);
            return null;
        });
    }

    public static WebServer createWebServer() {
        Config config = Config.create();

        CartService cartService = new CartService(config);

        HealthCheck dbHealth = () -> HealthCheckResponse
                .named("dbHealth")
                .state(cartService.healthCheck())
                .build();
        
        HealthSupport health = HealthSupport.builder()
                .addLiveness(HealthChecks.healthChecks())
                .addLiveness(dbHealth)
                .build();
        
        Routing routing = Routing.builder()
                      .register(AccessLogSupport.create(config.get("server.access-log")))
                      .register(MetricsSupport.create())
                      .register(health)                     // "/health"
                      .register("/carts", cartService)
                      .build();
        
        return WebServer.builder(routing)
                .config(config.get("server"))
                .addMediaSupport(JsonbSupport.create())
                .build();
    }

}
