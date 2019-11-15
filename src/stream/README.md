# Stream
A microservices-demo service that consumes shipping messages from OCI Streams.

This build is built, tested and released using gradle and maven.


# Build

## Java: building application jar

OCI-java-sdk is a dependency and needs to be manually uploaded to 
the local maven repository. 
* download oci-java-sdk
* install oci-java-sdk jar to local maven repository

`mvn install:install-file -Dfile=libs/oci-java-sdk-full-shaded-1.5.0.jar -DgroupId=com.oracle.oci -DartifactId=oci-java-sdk -Dversion=1.5.0 -Dpackaging=jar`


`mvn install`

## Docker

`docker build . --tag stream`

# Run

## Setup environment
The application depends on some environment variables to connect 
to OCI Streams. Edit secret/generate-secret.sh and replace your own values. Then
run the script file to create the secrets in Kubernetes.

`mvn spring-boot:run`

# Check

`curl http://localhost:8080/health`

# Use

This application runs continuously consuming messages in the OCI Stream.
Monitor the logs to observe messages being consumed.
The purpose of this application is to simulate a fulfiller, which picks up
messages for processing.

# Running on Kubernetes or OKE
Here are instructions to deploy this application to K8S

## Publish image to OCIR
`docker tag stream:latest phx.ocir.io/<your tenancy>/<repository>/stream:latest`

`docker push phx.ocir.io/<your tenancy>/<repository>/stream:latest`

## Create configmap
Edit the configmap.yaml file and add your environment values, then run
the command below to create the configmap to the cluster

`kubectl create -f configmap.yaml`

## Deploy

`kubectl create -f stream.yaml`




