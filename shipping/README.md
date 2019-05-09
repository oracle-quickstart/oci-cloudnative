# shipping
A microservices-demo service that provides shipping capabilities
with OCI Streams.

This is built, tested and released using gradle and maven.


# Build

## Java: building application jar

OCI-java-sdk is a dependency and needs to be manually uploaded to 
the local maven repository. 
* download oci-java-sdk
* install oci-java-sdk jar to local maven repository

`mvn install:install-file -Dfile=libs/oci-java-sdk-full-shaded-1.5.0.jar -DgroupId=com.oracle.oci -DartifactId=oci-java-sdk -Dversion=1.5.0 -Dpackaging=jar`


`mvn install`

## Docker

`docker build . --tag shipping`

# Run

## Setup environment
The application depends on some environment variables to connect 
to OCI Streams. Edit setup-env.sh and replace your own values. Then
source the script file to create the environment variables.

`mvn spring-boot:run`

# Check

`curl http://localhost:8080/health`
This returns the health of the application and connection to OCI Streams.

# Use

`curl http://localhost:8080`

## REST Interfaces

`http://<host>:8080/shipping`

Method: Post

Content-Type: application/json

The body should contain a JSON similar to this:
`{
	"id" : "123",
	"name" : "shipment A"
}`

The name is mandatory, the id is auto-generated if not sent.
This REST call causes the JSON message to be added to the OCI Stream

`http://{{host}}:8080/shipping/testbulk?count=7&message=test`

Method: Post

This REST call is for convenience in testing. It creates a bulk of
messages, where count is the number of messages generated and the 
text of each message is the string in message appended by the count.
Then these messages are added to the Stream.

# Running on Kubernetes or OKE
Here are instructions to deploy this application to K8S

## Publish image to OCIR
`docker tag shipping:latest phx.ocir.io/<your tenancy>/<repository>/shipping:latest`

`docker push phx.ocir.io/<your tenancy>/<repository>/shipping:latest`

## Create configmap
Edit the configmap.yaml file and add your environment values, then run
the command below to create the configmap to the cluster

`kubectl create -f configmap.yaml`

## Deploy

`kubectl create -f ship.yaml`




