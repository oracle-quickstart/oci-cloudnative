# Application Metadata
ARG APPLICATION_NAME="orders"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setup the build environment
FROM gradle:6.5 as buildenv

# create source folder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Refresh Deps.
COPY settings.gradle /usr/src/app
# copy buildscript and cache all dependencies
COPY build.gradle /usr/src/app
#
# ------------

# ------------
# Stage 2 : Build the application
#
FROM buildenv as appbuild
ARG APPLICATION_NAME
ARG VERSION
# Copy the source code.
# This layer is recreated only when there are actual source chnages 
COPY src /usr/src/app/src

# Install the application
RUN gradle clean test bootJar
RUN ls -ltr /usr/src/app/build/libs
# ------------

# ------------
# Stage 3 : Application container
#
FROM openjdk:13-slim
ARG APPLICATION_NAME
ARG VERSION

RUN apt-get update && apt-get install -y procps

# copy the generated application distribution
COPY --from=appbuild /usr/src/app/build/libs/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar

EXPOSE 80
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENV TNS_ADMIN=/wallet/
ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar --port=80
#
# ------------

