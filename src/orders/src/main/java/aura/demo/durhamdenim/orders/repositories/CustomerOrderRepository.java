package aura.demo.durhamdenim.orders.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import aura.demo.durhamdenim.orders.entities.CustomerOrder;

import java.util.List;

@RepositoryRestResource(path = "orders", itemResourceRel = "order")
public interface CustomerOrderRepository extends PagingAndSortingRepository<CustomerOrder, Long>  {
    @RestResource(path = "customer")
    public Page<CustomerOrder> findByCustomerId(@Param("custId") String id, Pageable p);
}

