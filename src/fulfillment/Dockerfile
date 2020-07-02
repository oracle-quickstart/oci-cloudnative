ARG APPLICATION_NAME="fulfillment"
ARG VERSION="0.0.1-SNAPSHOT"

# Stage 1 : Setup the build environment
FROM gradle:6.5-jdk11 as buildenv

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY settings.gradle /usr/src/app
# copy buildscript and cache all dependencies
COPY build.gradle /usr/src/app
COPY gradle.properties /usr/src/app
#RUN gradle --refresh-dependencies

# Stage 2 : Build the application
FROM buildenv as appbuild
# Copy the source code.
# This layer is recreated only when there are actual source chnages
COPY src /usr/src/app/src
# build an executable fat jar
RUN gradle clean assemble

# Stage 3 : Build a native image using GraalVM
FROM oracle/graalvm-ce:20.1.0-java11 as graalvm
COPY --from=appbuild /usr/src/app/build /home/app/fulfillment
WORKDIR /home/app/fulfillment/
RUN gu install native-image
RUN native-image --no-server  -cp libs/fulfillment-*-all.jar

# Step 4 : Build the final application image
FROM frolvlad/alpine-glibc
RUN apk update && apk add libstdc++
EXPOSE 80
COPY --from=graalvm /home/app/fulfillment/fulfillment /app/fulfillment
ENTRYPOINT ["/app/fulfillment", "-Djava.library.path=/app"]

