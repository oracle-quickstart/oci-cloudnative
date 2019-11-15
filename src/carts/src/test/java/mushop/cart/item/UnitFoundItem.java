package mushop.cart.item;

import org.junit.Test;

import mushop.cart.entities.Item;
import mushop.cart.item.FoundItem;

import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertThat;

public class UnitFoundItem {
    @Test
    public void findOneItem() {
        List<Item> list = new ArrayList<>();
        String testId = "testId";
        Item testAnswer = new Item(testId);
        list.add(testAnswer);
        FoundItem foundItem = new FoundItem(() -> list, () -> testAnswer);
        assertThat(foundItem.get(), is(equalTo(testAnswer)));
    }
}
