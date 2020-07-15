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

    public TestEntityManager getEntityManager() {
        return entityManager;
    }

    public void setEntityManager(TestEntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Autowired
    private TestEntityManager entityManager;

    public CustomerOrderRepository getOrderRepository() {
        return orderRepository;
    }

    public void setOrderRepository(CustomerOrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Autowired
    private CustomerOrderRepository orderRepository;

    @Test
    public void whenFindByName_thenReturnEmployee() {
        // given
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
        entityManager.persist(order);
        entityManager.flush();

        // when
        Page<CustomerOrder> found =  orderRepository.findByCustomerId("cust001", Pageable.unpaged());
        found.forEach(orderFound -> assertThat(orderFound.getId()).isEqualTo(order.getId()) );

    }

}