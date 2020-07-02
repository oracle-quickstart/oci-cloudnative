# Fulfillment
---
This service represents a fulfillment system in an e-commerce platform. 
The key idea demonstrated by this service is asynchronous, message based application design.
This allows us to scale the order management and fulfillment systems independently and provides 
for better fault tolerance. A messaging system also makes it easy for programs to communicate 
across different environments, languages, cloud providers and on-premise systems. Generally more 
throughput can be achieved with these designs than traditional synchronous, blocking models.

## Building

The application uses a `gradle` build. However for convenience, it can be build inside a 
docker container. To build the application execute the following command (from the repository root)

```shell script
docker build -t mushop-fulfillment:latest src/fulfillment
``` 
This is a multi stage that sets-up the the build environment and generates a docker image 
that runs the application. By default, the application that is built by `gradle` is processed by the 
GraalVM native image builder that compiles the application in to a native binary.


> **_NOTE:_** GraalVM's native image build is cpu and memory intensive, and could take a few minutes to complete.
> Make sure your docker daemon has been allocated enough CPUs and memory.

### Building a JVM application

If you would like to build the application as a standard executable jar file, we have 
provided an alternate `Dockerfile` that will skip the GraalVM based native image generation 
and build an image that uses a standard JVM to run the application. This is useful for either comparing 
GraalVM against the normal JVM execution, as well as for rapid development.

```shell script
docker build -t mushop-fulfillment:latest -f src/fulfillment/Dockerfile.jvm src/fulfillment
``` 

## Running 

The fulfillment service is included in the `docker-compose` configuration can simply be run using `docker-compose`.
To run the container stand-alone, simply run the following command.

```shell script
docker run -p 8087:80  mushop-fulfillment:local
``` 

This runs the container locally and exposes the application's api to the docker host's port `8099`.
You can validate the application state by simply making a health check request to 

```shell script
curl localhost:8087/health
``` 

### Application Configuration

There are a few attributes that are externally configurable. These are
|   |   |
|---|---|
| NATS_HOST  | The hostname for where NATS is reachable. Defaults to `localhost`  |
| SIMULATION_DELAY | The artificial time delay between the fulfillment service receiving a message from the orders service and it replying  (for demos). Defaults to 8s. Value is in milliseconds. |

## Metrics & Monitoring

The application uses micronaut-micrometer features to report metrics. Some of the JVM metrics are not reported as the application does not use a JVM in the default configuration.
To generate additional metrics, you can send fake message to indicate orders on to the NATS messaging platform. The fulfillment service does not validate the orders, and will "process" 
the orders by sending an acknowledgement with shipment information back to orders over the `mushop-shipments` channel. Orders does validate `orderId`s so there will be no accidental update 
of order records from the fake data.

To send messages at a high volume, use the `nats-box`.

```shell
kubectl run -i --rm --tty nats-box --image=synadia/nats-box --restart=Never
```

Once inside the container, use the following to send a stream of messages to the fulfillment service.

```shell
for x in `seq 1 300`; do echo $x; nats-pub -s nats://mushop-nats:4222 mushop-orders '{"orderId":2}';sleep 1;done
```

You should see some metrics being graphed in the dashboards.

## Micronaut & GraalVM

This application also uses the [Micronaut](https://micronaut.io/) - a lightweight framework 
that is particularly useful for building microservices. This Java application is also compiled 
in to a native binary using [GraalVM](https://www.graalvm.org/), to make the runtime even 
more light weight and faster by eliminating the JVM from the runtime. For comparison, the 
application when running on a JVM takes 2.2 seconds to start up. The same application 
when compiled with GraalVM in to a native binary starts up in 45 milliseconds.

## Messaging with NATS.io

The messaging system used is [nats.io](https://nats.io). NATS is a production ready messaging 
system that is extremely light weight. It's also a cloud-native CNCF project with Kubernetes and Prometheus 
integrations.