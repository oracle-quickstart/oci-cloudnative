package mushop.cart.repositories;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import mushop.cart.entities.Cart;

import java.util.List;

@RepositoryRestResource(exported = false)
public interface CartRepository extends PagingAndSortingRepository<Cart, String> {
    List<Cart> findByCustomerId(@Param("custId") String id);
}

