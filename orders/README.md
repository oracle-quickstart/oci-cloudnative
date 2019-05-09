# Orders

Orders is a micro service built using Spring Boot, using Oracle Autonomous Transaction Processing (ATP) as its data store. 

## Oracle ATP 

Oracle Autonomous Database is a family of products with each member of the family optimized by workload. Autonomous Data Warehouse (ADW) and Autonomous Transaction Processing (ATP) are the two products that have been released in 2018.
Java applications require Java Key Store (JKS) or Oracle wallets to connect to ATP or ADW. These wallet files can be downloaded from the service console. The enhancements in the JDBC driver in DB 18.3 simplify Java connectivity to ATP or ADW. 

This sample uses the Java Key Store (JKS) to demonstrate connection configuration.

## Orders Micro Service

The orders micro-service is a light weight application built on spring boot and leverages Spring JPA for data base connectivity. It exposes a REST API for order management operations. The full API doc ban be seen here 
<insert swagger docs>

This tutorial will focus on how you can introduce Oracle ATP to your JPA based applications for a flexible and elastic database that scales with your application. We start with the spring boot's standard - the in memory H2 database, and them move over to ATP. The application will be built using `gradle` and can be deployed locally using `docker-compose` or to the Oracle Kubernetes Engine (OKE) cluster for elastic scalability.

### Prerequisites

- **Provision ATP** : Sign in with your cloud credentials at cloud.oracle.com and create an ATP database by filling in few details. Refer to "Provisioning an Autonomous Transaction Processing" video for more details.
- Client Credentials : [Download the client credentials][download_client_creds] for the ATP instance.

### Application Configuration
Oracle's JDBC Drivers simplify connectivity to a cloud database. The [connection information can be downloaded][download_client_creds] from the service console, and the JDBC driver uses the information within to connect to the cloud database instance. More information on connecting to the database can be found [here][connection_info]. 
When using the JKS to authenticate the client application with the ATP instance, the following files from the client credentials package are required :

- **tnsnames.ora** - Provides aliases for the connection information. These aliases can be used directly in the JDBC url, and abstracts away the connection details from the application.
- **ojdbc.properties** - File to configure the connection properties. [Javadoc][ojdbc_javadoc]
- **keystore.jks** - The Java Keystore with keys pre-populated 
- **truststore.jks** - The Java Truststore with trusted certificates pre-populated

Both the key store and trust store are encrypted and its contents are protected with the password you provided when downloading them. You need this password to have your applications open and use the certs and private keys in these keystores, and in case you lose the password, the files can be downloaded again with a new password.

#### Application DataSource configuration
The easiest way to connect to the database is to keep the connection information in the downloaded files, and use the JDBC URL to point the drivers at this configuration. 
For setting up the JPA properties for a spring boot application, you can create a file named `application.properties` in `src/main/resources`. 
The configuration below refers to a TNS alias named `appdb_tp`. You will also notice that it sets the [TNS_ADMIN][TNS_ADMIN] location. This location contains the configuration files.
See [other ways to set the TNS_ADMIN][connection_info].

```text
spring.datasource.url=jdbc:oracle:thin:@appdb_tp?TNS_ADMIN=./config
spring.datasource.username=ADMIN
spring.datasource.password=Welcome123$$$
spring.datasource.driver.class=oracle.jdbc.driver.OracleDriver
spring.jpa.hibernate.ddl-auto=update
```

>Needless to say, in a production system, **you dont want to keep passwords in plaintext**. Most CI/CD systems or build tools can solve this for you, like using Kubernetes secrets or Hashicorp Vault

>If your application needs to connect to the ATP instance through a proxy server, [see this][proxy_tnsnames] for more information on including the proxy server information in your `tnsnames.ora`. This is common only when your application in running outside OCI, say, in your own data center or when running locally and connecting to ATP. 

#### Connection properties configuration
In the code sample above, the application is using a JDBC URL that points to a TNS alias and also sets the TNS_ADMIN location. 
The JDBC driver will look for a `tnsnames.ora` under this location to resolve the TNS alias. 

The driver will also look for the connection property configuration file `ojdbc.properties` in this location. See the [javadoc][ojdbc_javadoc] for other ways to provide this configuration.
A connection property configuration file template is included with the credential download package, however this uses an Oracle wallet by default. To swithch over to the Java Key Store based credentials,
comment out the wallet configuration and add in the properties for the JKS.

```text
# Wallet configuration commented out
# oracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=${TNS_ADMIN})))

oracle.net.tns_admin=./config
oracle.net.ssl_server_dn_match=true
javax.net.ssl.trustStore=${TNS_ADMIN}/truststore.jks
javax.net.ssl.trustStorePassword=Welcome123
javax.net.ssl.keyStore=${TNS_ADMIN}/keystore.jks
javax.net.ssl.keyStorePassword=Welcome123
```

Notice that we pointed the TNS_ADMIN location to `./config`, the runtime expects to find these configuration files in a config directory relative to the current working directory. For our sample, we can provide this to the runtime by creating a `src/dist/config` with the config files. The gradle distribution plugin will copy this to the distribution we are building.

#### Building and testing your application
Now that we have setup our application to connect to the ATP, lets build and run it. We are using the gradle distribution plugin to create a distribution package and shell scripts to start the application.
Generate the application distribution :

```bash
./gradlew clean bootJar

```

It will build the application, package it as executable archives (jar files and war files) that contain all of an application’s dependencies and can then be run with `java -jar`. For more information on the spring boot gradle plugin, see their [documentation][bootJar]

The installation has a layout

```none
<build>                
    |-classes/         [contains the class files]
    |-generated/       [generated code say, by annotation processors]
    |-libs/            [contains the built executable archive]
    |-resources/       [application resources like properties files]
    |-tmp/             [temp directory]
```

> **Using the oracle maven repository from gradle.** 
    The Oracle JDBC drivers are available in the oracle maven repository available at [maven.oracle.com](https://maven.oracle.com). To use the repository with gradle, you can configure it directly in your build script as described in the gradle [documentation][gradle_custom_repo]


## Containerization

Now that the application is buildable, lets make it's execution environment portable by containerizing it.
When we containerize the application, we need to focus on the following aspects

- Image optimization - We should take care to put only the required content in our container images, so that we reduce the image size. We should also consider the layers in the filesystem such that frequently changed files are on the top most layer so that image pulls can be faster since only the requireds layers ned to be pulled.
- Sensitive data - sensitive data on the image increases the exposure risk, so avoiding it makes our images more secure and configurable.
- Externalized configuration - externalizing configuration makes the the application images more portable and reusable.

There are many ways to create a docker image for a java application. Here we are going to take an approach that utilizes the docker multi-stage build to create an build environment and then build the application within that environment. We then extract the application distribution alone and create a separate image out of it.

> **Proprietary libraries and dependencies**  
A common pattern for enterprises to leverage proprietary libraries in their centralized build environments is using their own enterprise artifact repository (like artifactory) and importing the licensed dependencies there. Here however, for brevity and simplicity, we will populate and containerize a maven repository for the purpose. This approach still gives users a way to utilize an automated build process and version the build environments themselves, and can be a useful tool when an enterprise wide artifact repository is not available.

The Docker file for the build lays out the stages in the multi stage build.
It leverages a customized maven image that is seeded with the proprietary Oracle JDBC drivers. 

In the first stage, the build file is copied over and the primary dependencies are resolved. This ensures that these layers can be cached for a longer period improving the build performance.

In the second stage, the application sources are copied over in to the container and the application is built and a distribution is generated.

In the third and final stage is based on `openjdk:8-jdk-alpine` image to be lightweight and minimal. This forms the basis of our runtime container layer. The distribution generated in the build container is copied over to this image, and the entry points and other details are set.

>The maven repo is a separate project and the approach can be extended to create a docker image that provides the maven repository for a build process. This helps with controlling the dependencies used, and even performing builds completely offline. The repository image can be layed upon with additional libraries, building up the maven repo layer by layer. This gives enterprises a very portable repository structure with tight controls and versioning. To create the maven repo image, follow instructions [here][maven_jdbc].

The build can be triggered with the following commands.

``` bash
docker build -t orders:0.0.1 .

```
This builds the application and produces a docker image that contains the bare minimum required to run the orders application. The orders application requires access to the other micro services at runtime to process orders. In order to test our application, we can bring up our full suite of micro services using `docker-compose`, using the compose file provided.

The provided docker-compose yaml file refers to stable images that were pre-built. We can replace the orders image in this with the image that we just built to test our application against the other stable images.

Open the `docker-compose.yaml` and make the following changes

``` yaml
orders:
    image: orders:0.0.1
    ports:
     - 8085:80
    hostname: orders
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    environment:
      - JDBC_URL=jdbc:oracle:thin:@appdb_tp?TNS_ADMIN=./config
      - DB_USER=ADMIN
      - DB_PASSWORD=Welcome123$$$$$$
      - JAVA_OPTS=-Xms128m -Xmx128m -XX:+UseG1GC -Dlogging.level.aura.demo=TRACE -Djavax.net.ssl.trustStorePassword=Welcome123 -Djavax.net.ssl.keyStorePassword=Welcome123 -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false
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

