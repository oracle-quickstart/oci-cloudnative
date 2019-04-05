package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import oracle.ateam.sockshop.orders.domain.Customer;

@RepositoryRestResource(exported=false, path = "customers", itemResourceRel = "customer", collectionResourceRel = "customers")
public interface CustomerRepository extends PagingAndSortingRepository<Customer, Long>{
	

}
