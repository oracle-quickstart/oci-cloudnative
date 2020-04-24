package mushop.carts;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.io.InputStream;

import javax.json.Json;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;

import io.helidon.config.Config;
import oracle.jdbc.OracleConnection;
import oracle.soda.OracleCollection;
import oracle.soda.OracleCursor;
import oracle.soda.OracleDatabase;
import oracle.soda.OracleDocument;
import oracle.soda.rdbms.OracleRDBMSClient;
import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;

/**
 * Implements CartRepository using Oracle Database JSON collections. SODA is the
 * simple CRUD-based API that allows the application to interact with document
 * collections in the autonomous database.
 */
public class CartRepositoryDatabaseImpl implements CartRepository {

    /** Factory for SODA (simple oracle document access) api */
    private static final OracleRDBMSClient SODA;

    /** The name of the backing collection */
    private final String collectionName;

    /** Pool of reusable database connections */
    protected PoolDataSource pool;

    /** Used to automatically convert a Cart object to and from JSON */
    private Jsonb jsonb;

    private final static Logger log = Logger.getLogger(CartService.class.getName());

    public CartRepositoryDatabaseImpl(Config config) {
        try {
            System.setProperty("oracle.jdbc.fanEnabled", "false");
            String dbName = config.get("OADB_SERVICE").asString().get();
            String url = "jdbc:oracle:thin:@" + dbName + "?TNS_ADMIN=${TNS_ADMIN}";
            pool = PoolDataSourceFactory.getPoolDataSource();
            pool.setMaxStatements(50);
            pool.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
            pool.setURL(url);
            pool.setUser(config.get("OADB_USER").asString().get());
            pool.setPassword(config.get("OADB_PW").asString().get());
            collectionName = config.get("OADB_CARTS_COLLECTION").asString().get();

            // Create the carts collection if it does not exist
            try (OracleConnection con = (OracleConnection) pool.getConnection()) {
                OracleDatabase db = SODA.getDatabase(con);
                OracleCollection col = db.openCollection(collectionName);
                if (col == null) {
                    // Create a collection (see src/main/resources/metadata.json)
                    // It is OK if multiple processes try to create the collection at the
                    // same time. The collection will simply be returned by createCollection() if it
                    // already exists.
                    InputStream metaData = getClass().getClassLoader().getResourceAsStream("metadata.json");
                    OracleDocument collMeta = db.createDocumentFrom(metaData);
                    metaData.close();
                    col = db.admin().createCollection(collectionName, collMeta);
                }
                log.info("Connected to " + dbName);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        jsonb = JsonbBuilder.create();
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
            return doc == null ? null : jsonb.fromJson(doc.getContentAsString(), Cart.class);
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
            OracleDocument cartDoc = db.createDocumentFromString(cart.getId(), jsonb.toJson(cart));
            OracleCollection col = db.openCollection(collectionName);
            col.save(cartDoc);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** Selects carts based on a "query by example" */
    private List<Cart> getCarts(String filter) {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            OracleDocument filterDoc = db.createDocumentFromString(filter);

            OracleCursor carts = col.find().filter(filterDoc).getCursor();

            List<Cart> result = new ArrayList<Cart>();
            while (carts.hasNext()) {
                OracleDocument doc = carts.next();
                Cart cart = jsonb.fromJson(doc.getContentAsString(), Cart.class);
                result.add(cart);
            }
            return result;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public boolean healthCheck() {
        try (Connection con = pool.getConnection()) {
            OracleDatabase db = SODA.getDatabase(con);
            OracleCollection col = db.openCollection(collectionName);
            String name = col.admin().getName();
            return name != null;
        } catch (Exception e) {
            log.log(Level.SEVERE, "DB health-check failed.", e);
            return false;
        }
    }

    static {
        // Optimization: cache collection metadata to avoid extra roundtrips
        // to the database when opening a collection
        Properties props = new Properties();
        props.put("oracle.soda.sharedMetadataCache", "true");
        SODA = new OracleRDBMSClient(props);
    }
}
