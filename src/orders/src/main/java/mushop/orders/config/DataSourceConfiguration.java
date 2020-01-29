package mushop.orders.config;

import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class DataSourceConfiguration {

    @Autowired
    private Environment env;

    @Value("${mushop.orders.oadbservice}")
    private String db_Name;

    @Value("${mushop.orders.oadbuser}")
    private String db_user;

    @Value("${mushop.orders.oadbpw}")
    private String db_pass;
     
    @Bean
    public DataSource getDataSource() {
        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        //
        if("Mock".equalsIgnoreCase(db_Name)) {
            dataSourceBuilder.driverClassName("org.h2.Driver");
            dataSourceBuilder.url("jdbc:h2:mem:test");
            dataSourceBuilder.username("SA");
            dataSourceBuilder.password("");
        }else{
            dataSourceBuilder.driverClassName("oracle.jdbc.driver.OracleDriver");
            dataSourceBuilder.url("jdbc:oracle:thin:@"+db_Name+"?TNS_ADMIN=${TNS_ADMIN}");
            dataSourceBuilder.username(db_user);
            dataSourceBuilder.password(db_pass);
        }
        
        return dataSourceBuilder.build();
    }
}