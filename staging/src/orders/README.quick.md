# Orders

Orders is a micro service built using Spring Boot, using Oracle Autonomous Transaction Processing (ATP) as its data store. The services are exposed over HTTP, and when deployed over Kubernetes, can be scaled horizontally while other services discover and interact with this micro service over it's Service abstraction.

## Prerequisites

* Access to OCI Console
* Download SQL Developer. IDE plugins to connect to Oracle Database may require additional configuration for cloud connections, so SQL Developer is recommended.

## Oracle ATP

Oracle Autonomous Database is a family of products with each member of the family optimized by workload. Autonomous Data Warehouse (ADW) and Autonomous Transaction Processing (ATP) are the two products that have been released in 2018.
Java applications require Java Key Store (JKS) or Oracle wallets to connect to ATP or ADW. These wallet files can be downloaded from the service console. The enhancements in the JDBC driver in DB 18.3 simplify Java connectivity to ATP or ADW. 

This sample uses the Java Key Store (JKS) to demonstrate connection configuration.

## Orders Micro Service

The orders micro-service is a light weight application built on spring boot and leverages Spring JPA for data base connectivity. It exposes a REST API for order management operations.

This tutorial will focus on how you can introduce Oracle ATP to your JPA based applications for a flexible and elastic database that scales with your application. We start with the spring boot's standard - the in memory H2 database, and them move over to ATP. The application will be built using `gradle` and can be deployed locally using `docker-compose` or to the Oracle Kubernetes Engine (OKE) cluster for elastic scalability.

## Workshop - Step 1 - Provision ATP

- **Provision ATP** : Sign in with your cloud credentials at cloud.oracle.com and create an ATP database by filling in few details. Refer to "Provisioning an Autonomous Transaction Processing" video for more details.


## Workshop - Step 2 - Connect to your Cloud Database

Oracle's JDBC Drivers simplify connectivity to a cloud database. The [connection information can be downloaded][download_client_creds] from the service console, and the JDBC driver uses the information within to connect to the cloud database instance. More information on connecting to the database can be found [here][connection_info].

Connect to you cloud database with SQL developer, using your DBA privileges. To follow database best practices, we shall setup an application user with limited privileges for the application to use. In your SQL worksheet, run the script provided at



The credentials required for connecting to ATP are encrypted, and can be stored in Java Key Store files or Oracle Wallet files. This sample demonstrates the use of Java Key Store files fpr securely managing the ATP connection credentials. When using the JKS to authenticate the client application with the ATP instance, the following files from the client credentials package are required :

- **tnsnames.ora** - Provides aliases for the connection information. These aliases can be used directly in the JDBC url, and abstracts away the connection details from the application.
- **ojdbc.properties** - File to configure the connection properties. [Javadoc][ojdbc_javadoc]
- **keystore.jks** - The Java Keystore with keys pre-populated 
- **truststore.jks** - The Java Truststore with trusted certificates pre-populated

Both the key store and trust store are encrypted and its contents are protected with the password you provided when downloading them. You need this password to have your applications open and use the certs and private keys in these key stores, and in case you lose the password, the files can be downloaded again with a new password.

## Workshop - Step 3

Clone the repository and switch to the branch `orders-start`. 

```
git clone  https://github.com/junior/mushop.git
git checkout workshop/orders-start
```

The database connectivity information is externalized and configured through the `application.properties` file.

```text
spring.datasource.url=jdbc:oracle:thin:@${OADB_SERVICE}?TNS_ADMIN=./config
spring.datasource.username=${OADB_USER}
spring.datasource.password=${OADB_PW}
spring.datasource.driver.class=oracle.jdbc.driver.OracleDriver
spring.jpa.hibernate.ddl-auto=update
```
The properties file itself defers some configuration to the runtime, as can be seen from the usage of `${VARIABLE}` structures. These delegate the configuration to the runtime environment and are sourced from the environemnt at runtime. This prevents secure information from being baked in to the docker image and adds a facet of customization to the image.

## Workshop - Step 4

Now that we have setup our application to connect to the ATP, lets build and run it. The code contains a Dockerfile that sets up a build environment, builds the application and generates a docker container with the built application.
The build can be triggered with the following commands.

``` bash
docker build -t orders:0.0.1 .

```
This builds the application and produces a docker image that contains the bare minimum required to run the orders application. The orders application requires access to the other micro services at runtime to process orders. In order to test our application, we can bring up our full suite of micro services using `docker-compose`, using the compose file provided.

The provided docker-compose yaml file refers to stable images that were pre-built. We can replace the orders image in this with the image that we just built to test our application against the other stable images.

Open the `docker-compose.yaml` and make the following changes

``` yaml
orders:
    image: orders:1.0.0 # Update with the image tag you used above
    environment: # Update the values based on what you setup in the step above
      - OADB_USER=orders_user
      - OADB_PW=Default_Password123#
      - OADB_SERVICE=morders_tp
      - JAVA_OPTS=-Xms128m -Xmx256m -XX:+UseG1GC -Dlogging.level.mushop.orders=TRACE -Djavax.net.ssl.trustStorePassword=Welcome123 -Djavax.net.ssl.keyStorePassword=Welcome123 -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false

```
We have replaced the existing docker image with the image we built, and configured the environment parameters like `JDBC_URL`, `DB_USER`, `DB_PASSWORD` and `JAVA_OPTS` as required.

Now we can bring up all our services using docker compose

``` bash
docker-compose up -d
docker-compose logs -f orders # to see the logs from from our application
```
We can navigate to `localhost` to bring up the UI and place an order, or send http requests to localhost:8085 to directly hit the REST end point in our application (since we bound the application to 8085 on localhost, this is optional and useful only for testing)


### Pushing the image to OCIR

The `orders:0.0.1` image exists only on our local registry. For this image to be useful we need to be able to place this somewhere where our production runtime can pull the image from. OCI provides an enterprise grade Docker registry called OCIR. OCIR images are scoped to a region and needs to be tagged as follows :
`<region-code>.ocir.io/<tenancy-name>/<repo-name>/<image-name>:<tag>`
So for our orders application, lets tag it so that we can push this to OCIR

``` bash
docker tag orders:0.0.1 phx.ocir.io/acme-dev/mushop/orders:0.0.1
docker push phx.ocir.io/acme-dev/mushop/orders:0.0.1
```
Where acme-dev is your tenancy name, and mushop is the name of the repository.
We should update the `docker-compose.yml` with this image name as well, to make our docker-compose file portable.
You can find more details on [setting up access to OCIR here][OCIR_OBE]

## Kubernetes Deployment

Once the application has be pushed to the OCIR registry, we are ready to deploy this on a Kubernetes cluster. We setup a simple deployment with 3 replicas, all 3 connect to the same database from 3 different availability domains (for demonstration). We also create a LoadBalancer service, that distributes load across our 3 availability domains and provides for high availability and zero downtime re-deployments.

### Moving Sensitive information to Kubernetes secrets.

A Docker image is often a reusable component that is shared with different infrastructure and designed to run in various environments. Container images should be both reusable and secure. When an image contains embedded configuration or secrets it violates this rule and is neither secure nor reusable - imagine the development database password being embedded in to the image, you would need a different image for production. These values don’t belong in the image, they belong only in the running container. Secrets should always be provided by the container, not built into the image.

We can remove the sensitive data from the files and externalize them using kubernetes secrets. Secrets can be mounted as data volumes or be exposed as environment variables to be used by a container in a pod. In this example we will choose to expose them to a container as environment variables.
>Exposing secrets as environment variables is an inherently insecure approach as its openly available within the pod, and Secrets are simply base64 encoded only. However, we choose this approach to demonstrate the configuration without making changes to the application. Eventually we can move sensitive data to a more secure storage platform like Vault.

Kubernetes secrets are key value pairs and are stored in `etcd`. To manually create a secret we can use `kubectl`

``` bash
kubectl create secret generic atp-db-creds \
        --from-literal=db.user=<username> \
        --from-literal=db.password=<Password>

kubectl create secret generic atp-jks-creds \
        --from-literal="jks.auth=-Djavax.net.ssl.trustStorePassword=<TSPassword> -Djavax.net.ssl.keyStorePassword=<KSPassword>"
```

This creates two secrets managed by kubernetes, named `atp-db-creds` and `atp-jks-creds`. The Secret `atp-db-creds` contains two keys named `db.user` and `db.password` with their values. 
The kubernetes deployment manifest `atp-spring-jpa.yml` references these secrets and provides them to the runtime environment of the containers. The application now references the properties through the environment variables instead of reading them from a file. Alternatively the config files themselves could have been provided and mounted as volumes in to the container.


[connection_info]: https://docs.oracle.com/en/cloud/paas/atp-cloud/atpug/connect-jdbc-thin-wallet.html#GUID-F1D7452F-5E67-4418-B16B-B6A7B92F26A4
[spring_data_rest_sample]: https://github.com/spring-guides/gs-accessing-data-rest
[download_client_creds]: https://docs.oracle.com/en/cloud/paas/atp-cloud/atpug/connect-download-wallet.html#GUID-B06202D2-0597-41AA-9481-3B174F75D4B1
[ojdbc_javadoc]: https://docs.oracle.com/en/database/oracle/oracle-database/18/jajdb/oracle/jdbc/OracleConnection.html#CONNECTION_PROPERTY_CONFIG_FILE
[TNS_ADMIN]:https://docs.oracle.com/en/database/oracle/oracle-database/18/jajdb/oracle/jdbc/OracleConnection.html#CONNECTION_PROPERTY_TNS_ADMIN
[proxy_tnsnames]:https://docs.oracle.com/en/cloud/paas/atp-cloud/atpug/connect-jdbc-thin-wallet.html#GUID-6FA58792-CA32-47D0-A328-C6F797183B62
[gradle_custom_repo]:https://docs.gradle.org/current/userguide/repository_types.html#sub:authentication_schemes
[maven_jdbc]:https://orahub.oraclecorp.com/ateam/maven-jdbc
[bootJar]:https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/html/#packaging-executable
[OCIR_OBE]:https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html

