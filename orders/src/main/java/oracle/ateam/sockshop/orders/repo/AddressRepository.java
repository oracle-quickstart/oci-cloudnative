package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import oracle.ateam.sockshop.orders.domain.Address;

@RepositoryRestResource(exported=false, path = "addresses", itemResourceRel = "address", collectionResourceRel = "addresses")
public interface AddressRepository extends PagingAndSortingRepository<Address, Long>{

}
