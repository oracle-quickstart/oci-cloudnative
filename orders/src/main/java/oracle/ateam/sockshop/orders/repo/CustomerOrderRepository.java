package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import oracle.ateam.sockshop.orders.domain.CustomerOrder;

import java.util.List;

@RepositoryRestResource(path = "orders", itemResourceRel = "order", collectionResourceRel = "orders")
public interface CustomerOrderRepository extends PagingAndSortingRepository<CustomerOrder, String> {
    @RestResource(path = "customer")
    List<CustomerOrder> findByCustomerId(@Param("custId") Long id);
}

