package mushop.carts.repositories;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.micronaut.context.annotation.Primary;
import io.micronaut.context.annotation.Requires;
import io.micronaut.context.annotation.Value;
import io.micronaut.context.env.Environment;
import io.micronaut.context.event.StartupEvent;
import io.micronaut.runtime.event.annotation.EventListener;
import mushop.carts.entitites.Cart;
import oracle.jdbc.OracleConnection;
import oracle.soda.OracleCollection;
import oracle.soda.OracleCursor;
import oracle.soda.OracleDatabase;
import oracle.soda.OracleDocument;
import oracle.soda.rdbms.OracleRDBMSClient;
import oracle.ucp.jdbc.PoolDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.inject.Singleton;
import javax.json.Json;
import java.io.InputStream;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;


/**
 * Implements CartRepository using Oracle Database JSON collections. SODA is the
 * simple CRUD-based API that allows the application to interact with document
 * collections in the autonomous database.
 */
@Singleton
@Primary
@Requires(env = Environment.ORACLE_CLOUD)
public class CartRepositoryDatabaseImpl implements CartRepository {

    public static final Logger LOG = LoggerFactory.getLogger(CartRepositoryDatabaseImpl.class);

    /**
     * Factory for SODA (simple oracle document access) api
     */
    private static final OracleRDBMSClient SODA;

    static {
        // Optimization: cache collection metadata to avoid extra roundtrips
        // to the database when opening a collection
        Properties props = new Properties();
        props.put("oracle.soda.sharedMetadataCache", "true");
        SODA = new OracleRDBMSClient(props);
    }

    /**
     * The name of the backing collection
     */
    @Value("${carts.collection}")
    private String collectionName;

    /**
     * Pool of reusable database connections
     */
    @Inject
    protected PoolDataSource pool;

    /**
     * Used to automatically convert a Cart object to and from JSON
     */
    @Inject
    private ObjectMapper objectMapper;

    @EventListener
    public void onStartupEvent(StartupEvent startupEvent) {
        try {
            // Create the carts collection if it does not exist
            try (OracleConnection con = (OracleConnection) pool.getConnection()) {
                OracleDatabase db = SODA.getDatabase(con);
                LOG.info("Initializing DB connection...");
                OracleCollection col = db.openCollection(collectionName);
                if (col == null) {
                    LOG.info("Collection '{}' not exists, creating...", collectionName);
                    // Create a collection (see src/main/resources/metadata.json)
                    // It is OK if multiple processes try to create the collection at the
                    // same time. The collection will simply be returned by createCollection() if it
                    // already exists.
                    InputStream metaData = getClass().getClassLoader().getResourceAsStream("metadata.json");
                    OracleDocument collMeta = db.createDocumentFrom(metaData);
                    metaData.close();
                    col = db.admin().createCollection(collectionName, collMeta);
                }
                LOG.info("Connected to database.");
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public boolean deleteCart(String id) {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            int ct = col.find().key(id).remove();
            return ct > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Cart getById(String id) {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            OracleDocument doc = col.findOne(id);
            return doc == null ? null : objectMapper.readValue(doc.getContentAsString(), Cart.class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public List<Cart> getByCustomerId(String custId) {
        if (custId == null) {
            throw new IllegalArgumentException("The customer id must be specified");
        }
        // Create query by example like {"customerId" : "123"}
        String filter = Json.createObjectBuilder().add("customerId", custId).build().toString();

        return getCarts(filter);
    }

    @Override
    public void save(Cart cart) {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleDocument cartDoc = db.createDocumentFromString(cart.getId(), objectMapper.writeValueAsString(cart));
            OracleCollection col = db.openCollection(collectionName);
            col.save(cartDoc);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Selects carts based on a "query by example"
     */
    private List<Cart> getCarts(String filter) {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            OracleDocument filterDoc = db.createDocumentFromString(filter);

            OracleCursor carts = col.find().filter(filterDoc).getCursor();

            List<Cart> result = new ArrayList<Cart>();
            while (carts.hasNext()) {
                OracleDocument doc = carts.next();
                Cart cart = objectMapper.readValue(doc.getContentAsString(), Cart.class);
                result.add(cart);
            }
            return result;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // TODO: SODA healthcheck endpoint
    @Override
    public boolean healthCheck() {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            String name = col.admin().getName();
            return name != null;
        } catch (Exception e) {
            LOG.info("DB health-check failed.", e);
            return false;
        }
    }

}
