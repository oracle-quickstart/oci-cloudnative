package mushop.carts.test;

import io.micronaut.core.type.Argument;
import io.micronaut.http.HttpRequest;
import io.micronaut.http.HttpResponse;
import io.micronaut.http.HttpStatus;
import io.micronaut.http.client.RxHttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.test.extensions.junit5.annotation.MicronautTest;
import mushop.carts.entitites.Cart;
import mushop.carts.entitites.Item;
import org.junit.jupiter.api.Test;

import javax.inject.Inject;
import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

@MicronautTest
public class TestCartService {

    @Inject
    @Client("/")
    RxHttpClient httpClient;

    @Test
    public void testStoreCart() {
        Item i = new Item();
        i.setUnitPrice(BigDecimal.valueOf(123));
        i.setQuantity(47);
        i.setItemId("I123");

        Cart c = new Cart();
        c.setCustomerId("c1");
        c.getItems().add(i);

        HttpResponse<Cart> created = httpClient.exchange(HttpRequest.POST("/carts/" + c.getId(), c), Cart.class).blockingSingle();
        assertEquals(HttpStatus.CREATED, created.getStatus());
        assertEquals(c.getId(), created.body().getId());

        HttpResponse<List<Item>> items = httpClient.exchange(HttpRequest.GET("/carts/" + c.getId() + "/items"), Argument.listOf(Item.class)).blockingSingle();
        assertEquals(1, items.body().size());
        assertEquals(i.getId(), items.body().get(0).getId());

        HttpResponse<Cart> deleteItem = httpClient.exchange(HttpRequest.DELETE("/carts/" + c.getId() + "/items/" + i.getItemId()), Cart.class).blockingSingle();
        assertEquals(HttpStatus.OK, deleteItem.getStatus());

        items = httpClient.exchange(HttpRequest.GET("/carts/" + c.getId() + "/items"), Argument.listOf(Item.class)).blockingSingle();
        assertEquals(0, items.body().size());
    }
}
