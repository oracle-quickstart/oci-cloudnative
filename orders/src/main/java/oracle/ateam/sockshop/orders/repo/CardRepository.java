package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import oracle.ateam.sockshop.orders.domain.Card;
@RepositoryRestResource(exported=false, path = "cards", itemResourceRel = "card", collectionResourceRel = "cards")
public interface CardRepository extends PagingAndSortingRepository<Card, Long> {

}
