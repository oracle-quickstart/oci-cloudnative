package mushop.carts;

import io.helidon.common.http.Http;
import io.helidon.common.http.Http.RequestMethod;
import io.helidon.config.Config;
import io.helidon.metrics.RegistryFactory;
import io.helidon.webserver.Routing.Rules;
import io.helidon.webserver.ServerRequest;
import io.helidon.webserver.ServerResponse;
import io.helidon.webserver.Service;
import org.eclipse.microprofile.metrics.Counter;
import org.eclipse.microprofile.metrics.Meter;
import org.eclipse.microprofile.metrics.MetricRegistry;
import org.eclipse.microprofile.metrics.Timer;

import java.util.Collections;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CartService implements Service {

    /**
     * A reserved dbname to use for an in-memory repository instead of the
     * autonomous database
     */
    private static final String MOCKDB = "mock";

    private final static Logger log = Logger.getLogger(CartService.class.getName());

    /** @see https://github.com/oracle/helidon/issues/1172 */
    private static final Set<RequestMethod> PATCH = Collections.singleton(Http.RequestMethod.create("PATCH"));

    private CartRepository carts;

    private final MetricRegistry registry = RegistryFactory.getInstance().getRegistry(MetricRegistry.Type.APPLICATION);
    private final Meter newCartMeter = registry.meter("carts_create_meter");
    private final Meter updateCartMeter = registry.meter("carts_update_meter");
    private final Counter deleteCartCounter = registry.counter("carts_delete");
    private final Timer saveCartTimer = registry.timer("carts_save_timer");
    private final Timer dbConnectTimer = registry.timer("carts_db_conn_timer");

    public CartService(Config config) {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        Boolean connected = false;
        String dbName = config.get("OADB_SERVICE").asString().get();
        if (MOCKDB.equalsIgnoreCase(dbName)) {
            log.warning("Connecting to a Mock Database. Data is not persisted.");
            carts = new CartRepositoryMemoryImpl();
        } else {
            while (!connected) {
                try {
                    Future<Boolean> result = executorService.submit(() -> {
                        try {
                            log.info("Connecting to " + dbName);
                            Timer.Context context = dbConnectTimer.time();
                            carts = new CartRepositoryDatabaseImpl(config);
                            context.close();
                            log.info("Connected to " + dbName);
                            return Boolean.TRUE;
                        } catch (Exception ex) {
                            log.warning("Connect failed. Retrying.");
                            log.log(Level.SEVERE, ex.getMessage(), ex);
                            Thread.sleep(5000l);
                            return Boolean.FALSE;
                        }

                    });
                    connected = result.get();
                } catch (Exception e) {
                    log.log(Level.SEVERE, e.getMessage(), e);
                }

            }

        }
    }

    @Override
    public void update(Rules rules) {
        rules.get("/{cartId}/items", this::getCartItems).delete("/{cartId}", this::deleteCart)
                .delete("/{cartId}/items/{itemId}", this::deleteCartItem).post("/{cartId}", this::postCart)
                .anyOf(PATCH, "/{cartId}/items", this::updateCartItem);
    }

    /**
     * GET /{cartId}/items
     * 
     * Returns the list of items in a cart.
     */
    public void getCartItems(ServerRequest request, ServerResponse response) {
        Cart result = null;
        try {
            String cartId = request.path().param("cartId");
            result = carts.getById(cartId);
            if (result == null) {
                response.status(404).send();
                return;
            }
        } catch (Exception e) {
            log.log(Level.SEVERE, "getCartItems failed.", e);
            sendError(response, e.getMessage());
            return;
        }
        response.status(200).send(result.getItems());
    }

    /**
     * DELETE /{cartId}
     * 
     * Delete a cart.
     */
    public void deleteCart(ServerRequest request, ServerResponse response) {
        try {
            if (carts.deleteCart(request.path().param("cartId"))) {
                deleteCartCounter.inc();
                response.status(200).send();
            } else {
                response.status(404).send();
            }
        } catch (Exception e) {
            log.log(Level.SEVERE, "deleteCart failed.", e);
            sendError(response, e.getMessage());
            return;
        }
    }

    /**
     * DELETE /{cartId}/items/{itemId}
     * 
     * Deletes item in a cart.
     */
    public void deleteCartItem(ServerRequest request, ServerResponse response) {

        String cartId = request.path().param("cartId");
        String itemId = request.path().param("itemId");
        try {
            Cart cart = carts.getById(cartId);
            if (cart == null || !cart.removeItem(itemId)) {
                response.status(404).send();
                return;
            }
            Timer.Context context = saveCartTimer.time();
            carts.save(cart);
            context.close();
            updateCartMeter.mark();
            response.status(200).send();
        } catch (Exception e) {
            log.log(Level.SEVERE, "deleteCartItem failed.", e);
            sendError(response, e.getMessage());
            return;
        }
    }

    /**
     * POST /{cartId}
     * 
     * Adds or updates a cart. If the cartId does not exist, a new cart is added. If
     * the cartId does exist, the given cart is merged in to the existing one. This
     * method is used to add additional items to a cart.
     */
    public void postCart(ServerRequest request, ServerResponse response) {
        String cartId = request.path().param("cartId");

        try {
            request.content().as(Cart.class).thenAccept(newCart -> {
                try {
                    Cart cart = carts.getById(cartId);
                    if (cart == null) {
                        newCart.setId(cartId);
                        Timer.Context context = saveCartTimer.time();
                        carts.save(newCart);
                        context.close();
                        newCartMeter.mark();
                        response.status(201).send(); // created
                    } else {
                        cart.merge(newCart);
                        Timer.Context context = saveCartTimer.time();
                        carts.save(cart);
                        context.close();
                        updateCartMeter.mark();
                        response.status(200).send(); // ok
                    }
                } catch (Exception e) {
                    log.log(Level.SEVERE, "postCart failed.", e);
                    sendError(response, e.getMessage());
                    return;
                }
            });
        } catch (Exception e) {
            log.log(Level.SEVERE, "postCart failed.", e);
            sendError(response, e.getMessage());
            return;
        }
    }

    /**
     * PUT /{cartId}/items
     * 
     * Updates the quantity of an item in the cart.
     */
    public void updateCartItem(ServerRequest request, ServerResponse response) {
        String cartId = request.path().param("cartId");
        try {
            request.content().as(Item.class).thenAccept(qItem -> {
                try {
                    Cart cart = carts.getById(cartId);
                    if (cart == null) {
                        response.status(404).send();
                        return;
                    }
                    for (Item item : cart.getItems()) {
                        if (item.getItemId().equals(qItem.getItemId())) {
                            item.setQuantity(qItem.getQuantity());
                            Timer.Context context = saveCartTimer.time();
                            carts.save(cart);
                            context.close();
                            updateCartMeter.mark();
                            response.status(200).send();
                            return;
                        }
                    }
                    response.status(404).send();
                } catch (Exception e) {
                    sendError(response, e.getMessage());
                    return;
                }
            });
        } catch (Exception e) {
            log.log(Level.SEVERE, "updateCartItem failed.", e);
            sendError(response, e.getMessage());
            return;
        }
    }

    private void sendError(ServerResponse response, String message) {
        HashMap<String, String> error = new HashMap<String, String>();
        error.put("errorMessage", message);
        response.status(400).send(error);
    }

    public boolean healthCheck() {
        try {

            return carts == null ? false : carts.healthCheck();
        } catch (Exception e) {
            log.log(Level.SEVERE, "DB health-check failed.", e);
            return false;
        }
    }

}
