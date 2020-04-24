
# Shopping Cart

A microservice demo that stores the MuShop shopping carts. The service is written in Java and makes use of the following components:

  * **Autonomous Database JSON** - Each shopping cart is stored in the autonomous database as a JSON document using [SODA (Simple Oracle Document Access)](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/).  The microservice stores cart data using simple create, read, update, and delete operations over a collection of JSON documents.  For example:
    ```Java
    OracleCollection col = db.openCollection("carts");
    // insert a cart
    OracleDocument doc = db.createDocumentFromString("{\"customerId\" : 123, \"items\" : [...] }")
    col.save(doc);

    // get a cart
    doc = col.find().filter("{\"customerId\" : 123}").getOne()
    ```

    See [src/main/java/mushop/carts/CartRepositoryDatabaseImpl.java](src/main/java/mushop/carts/CartRepositoryDatabaseImpl.java)

    Why JSON in the Autonomous Database?

    * **Flexibility** - the shopping cart service can evolve to store new attributes without modifying a database schema or existing SQL queries and DML.  [JSON-B](http://json-b.net/) is used to automatically map basic [Cart](src/main/java/mushop/carts/Cart.java) objects to and from JSON. Storing a new Cart attribute only requires modifying the Cart class (not the database, queries, or other parts of the application code).

    * **Performance** - JSON documents can be read and written with consistent **single-digit millisecond latency at scale**. The autonomous database can manually or automatically scale out to increase throughput based on demand.  A cart is read from the database without requiring any joins between underlying tables.  An ORM solution, such as [JPA](https://en.wikipedia.org/wiki/Java_Persistence_API), would likely use joins between an underlying _cart_ and _item_ table each time the [Cart](src/main/java/mushop/carts/Cart.java) object is retrieved.  Such joins can be prohibitively expensive for highly concurrent workloads. Also, low-latency, high-throughput JSON performance is maintained **without sacrificing consistency, durability, or isolation** (sacrifices typically made in NoSQL databases).

    * **Analytics** - Oracle Database is the world's leading [translytic database](https://blogs.oracle.com/database/oracle-1-in-forresters-translytical-data-platforms-wave-v2).  Even though the cart microservice is written without using SQL, SQL can still be used to access JSON collections.  The data can be exposed, in-place, to existing analytics tools that don't necessarily support JSON and might use older database drivers.  There are no special restrictions on the types of queries that can be used over JSON collections.  In contrast, NoSQL databases typically have significant restrictions on the types of joins and subqueries that can be expressed and don't support standard SQL drivers such as JDBC.

      ```SQL
      SELECT c.json_document.customerId
      FROM carts c
      ```
      See [sql/examples.sql](sql/examples.sql) for more examples of how SQL can be used over the _carts_ collection used by this service.

    * **Multimodel** - Data stored in JSON collections can be queried along side other types of data in Oracle Database such as relational, geospatial, graph, and so on.  See [sql/examples.sql](sql/examples.sql) for an example that joins the _cart_ collection with other relational tables.

    * **Autonomous** - JSON collections benefit from all the general features of the [autonomous database](https://www.oracle.com/database/what-is-autonomous-database.html) such as advanced security, automated patching, automated backups, and so on.

    * **Cost** - JSON collections are in the [always-free tier](https://www.oracle.com/cloud/free/) of the autonomous database.  You can run this shopping cart service for free, forever, in the Oracle Cloud.

  * **Helidon** - The REST services are built using [Helidon SE](https://helidon.io/), a lightweight, fast platform for building microservices in Java.  Helidon makes it easy to map REST URL patterns to Java functions.

    ```java
     public void update(Rules rules) {
        rules.get("/{cartId}/items", this::getCartItems);
     }

     public void getCartItems(ServerRequest request, ServerResponse response) {
        String cartId = request.path().param("cartId");
        result = carts.getById(cartId);
        response.status(200).send(result.getItems());
     }
     ```
     See [src/main/java/mushop/carts/CartService.java](src/main/java/mushop/carts/CartService.java)

     Helidon is designed to support cloud-native applications. It comes with built-in support for things like health checks, metrics, tracing, and fault tolerance.  These features make it work well for deployment in Docker and Kubernetes.

# Usage

The MuShop application deploys this serivce using Helm, Kubernetes, and Docker. (See
[/deploy/complete/helm-chart/](https://github.com/oracle-quickstart/oci-cloudnative/tree/master/deploy/complete/helm-chart)).  However, you can also start the shopping cart service standalone and interact with it direcly using REST tools such as [curl](https://curl.haxx.se/) or [Insomnia](https://insomnia.rest/).

## Maven

You can build and run the service directly using Maven and Java. Ensure you have Java 1.8 or later and Maven 3.x or later.  Set JAVA_HOME and PATH variables.  For example:
```bash
export JAVA_HOME=/path/to/java
export PATH=$JAVA_HOME/bin:/path/to/maven/bin
```

### Build
To compile the service:

```bash
mvn clean package -DskipTests
```
This will run the tests and produce the jar `target/carts-1.1.0-SNAPSHOT.jar`

### Run

First, provision an [Autonomous Database instance](https://www.oracle.com/cloud/free/) (the free-tier works fine).  Then run the following command.

```bash
export TNS_ADMIN=/path/to/wallet
java -Dserver.port=8080 \
     -DOADB_SERVICE=mushop_high \
     -DOADB_USER=CARTS_USER \
     -DOADB_PW=MyPassword \
     -jar ./target/carts-1.1.0-SNAPSHOT.jar
```
But replace:
* `/path/to/wallet` with the location of your Autonomous Database wallet
* `mushop_high` with the actual name of the service in `$TNS_ADMIN/tnsnames.ora`
* `CARTS_USER` with the database username
* `MyPassword` with the database password

You should be able to access the service with a REST client.  For example:
```bash
curl -i -X POST -H "Content-Type: application/json" \
  --data '{"customerId" : 123, "items" : [{"itemId":"MU-US-005","quantity":1,"unitPrice":9.5}]}' \
  http://localhost:8080/carts/cart2
```
## Docker

You can run the service standalone using [Docker](http://docker.com) directly.

Build the image:
```bash
docker build -t mushop/carts .
```

Start the container:
```bash
docker run -it \
   --env OADB_SERVICE=mushop_high \
   --env OADB_USER=CARTS_USER \
   --env OADB_PW=MyPassword \
   --env TNS_ADMIN=/wallet \
   --volume /local/path/to/wallet:/wallet \
   -p 8080:80 \
   mushop/carts
```

You should be able to access the service with a REST client.  For example:
```bash
curl -i -X POST -H "Content-Type: application/json" \
  --data '{"customerId" : 123, "items" : [{"itemId":"MU-US-005","quantity":1,"unitPrice":9.5}]}' \
  http://localhost:8080/carts/cart2
```
