package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import oracle.ateam.sockshop.orders.domain.Item;
@RepositoryRestResource(exported=false, path = "items", itemResourceRel = "item", collectionResourceRel = "items")
public interface ItemRepository extends PagingAndSortingRepository<Item, Long>{

}
