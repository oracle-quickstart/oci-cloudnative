package oracle.ateam.sockshop.orders.repo;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import oracle.ateam.sockshop.orders.domain.Shipment;

@RepositoryRestResource(exported=false, path = "shipments", itemResourceRel = "shipment", collectionResourceRel = "shipments")
public interface ShipmentRepository extends PagingAndSortingRepository<Shipment, Long>{

}
