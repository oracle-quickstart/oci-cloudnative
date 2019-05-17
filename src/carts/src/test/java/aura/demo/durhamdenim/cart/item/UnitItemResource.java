package aura.demo.durhamdenim.cart.item;

import aura.demo.durhamdenim.cart.entities.Item;
import org.junit.Test;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;


public class UnitItemResource {
    private ItemDAO itemDAO = new ItemDAO.Fake();

    @Test
    public void testCreateAndDestroy() {
        Item item = new Item("itemId", "testId", 1, 0F);
        ItemResource itemResource = new ItemResource(itemDAO, () -> item);
        itemResource.create().get();
        assertThat(itemDAO.findOne(item.id()), is(equalTo(item)));
        itemResource.destroy().run();
        assertThat(itemDAO.findOne(item.id()), is(nullValue()));
    }

    @Test
    public void mergedItemShouldHaveNewQuantity() {
        Item item = new Item("itemId", "testId", 1, 0F);
        ItemResource itemResource = new ItemResource(itemDAO, () -> item);
        assertThat(itemResource.value().get(), is(equalTo(item)));
        Item newItem = new Item(item, 10);
        itemResource.merge(newItem).run();
        assertThat(itemDAO.findOne(item.id()).quantity(), is(equalTo(newItem.quantity())));
    }
}
