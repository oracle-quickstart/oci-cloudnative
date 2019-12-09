package mushop.carts;

import io.helidon.config.Config;
import io.helidon.health.HealthSupport;
import io.helidon.health.checks.HealthChecks;
import io.helidon.media.jsonb.server.JsonBindingSupport;
import io.helidon.metrics.MetricsSupport;
import io.helidon.webserver.Routing;
import io.helidon.webserver.Routing.Builder;
import io.helidon.webserver.ServerConfiguration;
import io.helidon.webserver.WebServer;

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
        ServerConfiguration serverConfig = ServerConfiguration.create(config.get("server"));

        CartService cartService = new CartService(config);
        
        HealthSupport health = HealthSupport.builder()
                .addLiveness(HealthChecks.healthChecks())
                .build();
        
        Builder routes = Routing.builder()
                      .register(JsonBindingSupport.create())
                      .register(MetricsSupport.create())    // "/metrics" 
                      .register(health)                     // "/health"
                      .register("/carts", cartService);
        
        return WebServer.create(serverConfig, routes);
    }

}
