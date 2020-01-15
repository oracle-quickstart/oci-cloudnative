package mushop.carts;

import java.util.Collections;
import java.util.HashMap;
import java.util.Locale;
import java.util.Set;
import java.util.logging.Logger;

import io.helidon.common.http.Http;
import io.helidon.common.http.Http.RequestMethod;
import io.helidon.config.Config;
import io.helidon.webserver.Routing.Rules;
import io.helidon.webserver.ServerRequest;
import io.helidon.webserver.ServerResponse;
import io.helidon.webserver.Service;

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

    public CartService(Config config) {
        String dbName = config.get("OADB_SERVICE").asString().get();
        log.info("Connecting to "+dbName);
        if (MOCKDB.equalsIgnoreCase(dbName)) {
            carts = new CartRepositoryMemoryImpl();
            log.warning("Connected to a Mock Database. Data is not persisted.");
        } else {
                carts = new CartRepositoryDatabaseImpl(config);
                log.info("Connected to "+dbName);
        }
    }

    @Override
    public void update(Rules rules) {
        rules.get("/{cartId}/items", this::getCartItems)
            .delete("/{cartId}", this::deleteCart)
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
                response.status(200).send();
            } else {
                response.status(404).send();
            }
        } catch (Exception e) {
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
            carts.save(cart);
            response.status(200).send();
        } catch (Exception e) {
            e.printStackTrace();
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
                Cart cart = carts.getById(cartId);
                if (cart == null) {

                    newCart.setId(cartId);
                    carts.save(newCart);
                    response.status(201).send(); // created
                } else {
                    cart.merge(newCart);
                    carts.save(cart);
                    response.status(200).send(); // ok
                }
            });
        } catch (Exception e) {
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
                Cart cart = carts.getById(cartId);
                if (cart == null) {
                    response.status(404).send();
                    return;
                }
                for (Item item : cart.getItems()) {
                    if (item.getItemId().equals(qItem.getItemId())) {
                        item.setQuantity(qItem.getQuantity());
                        carts.save(cart);
                        response.status(200).send();
                    }
                }
                response.status(404).send();
            });
        } catch (Exception e) {
            sendError(response, e.getMessage());
            return;
        }
    }

    private void sendError(ServerResponse response, String message) {
        HashMap<String, String> error = new HashMap<String, String>();
        error.put("errorMessage", message);
        response.status(400).send(error);
    }

    public boolean healthCheck(){
        return carts.healthCheck();
    }
    
}
