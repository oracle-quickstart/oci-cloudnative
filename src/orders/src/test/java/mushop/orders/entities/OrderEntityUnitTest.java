package mushop.orders.entities;

import mushop.orders.repositories.CustomerOrderRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Collections;
import java.util.Date;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
public class OrderEntityUnitTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private CustomerOrderRepository orderRepository;

    public CustomerOrderRepository getOrderRepository() {
        return orderRepository;
    }

    public void setOrderRepository(CustomerOrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public TestEntityManager getEntityManager() {
        return entityManager;
    }

    public void setEntityManager(TestEntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public CustomerOrder createOrderObj(){
        Address address = new Address("id","000","street","city","00000","coutry");
        Card card = new Card("id","0000000000000000","00/00","000");
        Customer customer = new Customer("cust001","first","last","user", Collections.emptyList(),Collections.emptyList());
        CustomerOrder order = new CustomerOrder(null,
                customer,
                address,
                card,
                null,
                null,
                new Date(),
                0.0f);
        return order;
    }

    @Test
    public void findOrdersByCustomerId() {
        CustomerOrder order = createOrderObj();
        entityManager.persist(order);
        entityManager.flush();
        Long orderId = order.getId();
        Page<CustomerOrder> found =  orderRepository.findByCustomerId("cust001", Pageable.unpaged());
        found.forEach(orderFound -> assertThat(orderFound.getId()).isEqualTo(orderId) );

    }

    @Test
    public void findOrderByInvalidIdFails(){
        CustomerOrder order = createOrderObj();
        entityManager.persist(order);
        entityManager.flush();
        Long orderId = order.getId();
        assertThat(orderRepository.findById(orderId+50).isPresent()).isFalse();
    }

    @Test
    public void findOrderByIdSucceeds(){
        CustomerOrder order = createOrderObj();
        entityManager.persist(order);
        entityManager.flush();
        Long orderId = order.getId();
        assertThat(orderRepository.findById(orderId).isPresent()).isTrue();
    }

    @Test
    public void addressIsPersisted(){
        CustomerOrder order = createOrderObj();
        entityManager.persist(order);
        entityManager.flush();
        Long orderId = order.getId();
        assertThat(orderRepository.findById(orderId).get().getAddress()).isEqualTo(order.getAddress());
    }

}