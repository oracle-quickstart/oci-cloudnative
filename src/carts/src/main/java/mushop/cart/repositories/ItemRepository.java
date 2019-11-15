package mushop.cart.repositories;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import mushop.cart.entities.Item;

@RepositoryRestResource
public interface ItemRepository extends PagingAndSortingRepository<Item, String> {
}
