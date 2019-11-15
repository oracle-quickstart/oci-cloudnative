package mushop.cart.cart;

import org.hamcrest.collection.IsCollectionWithSize;
import org.junit.Test;

import mushop.cart.cart.CartContentsResource;
import mushop.cart.cart.CartDAO;
import mushop.cart.cart.Resource;
import mushop.cart.entities.Cart;
import mushop.cart.entities.Item;

import static org.hamcrest.MatcherAssert.assertThat;


public class UnitCartContentsResource {
    private final String customerId = "testId";
    private final CartDAO.Fake fakeDAO = new CartDAO.Fake();
    private final Resource<Cart> fakeCartResource = new Resource.CartFake(customerId);

    @Test
    public void shouldAddAndReturnContents() {
        CartContentsResource contentsResource = new CartContentsResource(fakeDAO, () -> fakeCartResource);
        Item item = new Item("testId");
        contentsResource.add(() -> item).run();
        assertThat(contentsResource.contents().get(), IsCollectionWithSize.hasSize(1));
        //TODO: (DNP) remove comment
        //assertThat(contentsResource.contents().get(), containsInAnyOrder(item));
    }

    @Test
    public void shouldStartEmpty() {
        CartContentsResource contentsResource = new CartContentsResource(fakeDAO, () -> fakeCartResource);
        assertThat(contentsResource.contents().get(), IsCollectionWithSize.hasSize(0));
    }

    @Test
    public void shouldDeleteItemFromCart() {
        CartContentsResource contentsResource = new CartContentsResource(fakeDAO, () -> fakeCartResource);
        Item item = new Item("testId");
        contentsResource.add(() -> item).run();
        assertThat(contentsResource.contents().get(), IsCollectionWithSize.hasSize(1));
        //TODO: (DNP) remove comment
        //assertThat(contentsResource.contents().get(), containsInAnyOrder(item));
        Item item2 = new Item(item.itemId());
        contentsResource.delete(() -> item2).run();
        assertThat(contentsResource.contents().get(), IsCollectionWithSize.hasSize(0));
    }
}
