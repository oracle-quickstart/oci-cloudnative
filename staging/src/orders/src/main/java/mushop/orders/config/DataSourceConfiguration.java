package mushop.orders.config;

import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class DataSourceConfiguration {

    @Autowired
    private Environment env;    
     
    @Bean
    public DataSource getDataSource() {
        DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        String db_Name = env.getProperty("OADB_SERVICE");
        if("Mock".equalsIgnoreCase(db_Name)) {
            dataSourceBuilder.driverClassName("org.h2.Driver");
            dataSourceBuilder.url("jdbc:h2:mem:test");
            dataSourceBuilder.username("SA");
            dataSourceBuilder.password("");
        }else{
            dataSourceBuilder.driverClassName("oracle.jdbc.driver.OracleDriver");
            dataSourceBuilder.url("jdbc:oracle:thin:@"+db_Name+"?TNS_ADMIN=${TNS_ADMIN}");
            dataSourceBuilder.username(env.getProperty("OADB_USER"));
            dataSourceBuilder.password(env.getProperty("OADB_PW"));
        }
        
        return dataSourceBuilder.build();
    }
}