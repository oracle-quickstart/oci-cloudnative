ARG APPLICATION_NAME="queuemaster"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setting up the build environment
# 
FROM openjdk:8-jdk-alpine as buildenv
# ----
# Install some basic tools
RUN apk add --no-cache curl tar bash

# Install Maven
ARG USER_HOME_DIR="/root"
ARG MAVEN_VERSION=3.6.0
RUN mkdir -p /usr/share/maven && \
curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Setup OCI libraries
ARG GROUP_ID="com.oracle.oci"
ARG ARTIFACT_ID="oci-java-sdk"
ARG ARTIFACT_VERSION="1.5.0"

## Install dependencies to the local repo and cleanup
COPY ./libs/oci-java-sdk-full-shaded-1.5.0.jar /root/oci-java-sdk-full-shaded-1.5.0.jar
RUN mvn install:install-file -Dfile=/root/oci-java-sdk-full-shaded-1.5.0.jar -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${ARTIFACT_VERSION} -Dpackaging=jar &&  rm /root/*.jar

#
# create source folder
#
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#
# Get Gradle.
#
COPY ./settings.gradle /usr/src/app
COPY ./gradle /usr/src/app/gradle
COPY ./gradlew /usr/src/app
RUN ./gradlew --refresh-dependencies
#
# copy buildscript and cache all dependencies
#
COPY ./build.gradle /usr/src/app
RUN ./gradlew --refresh-dependencies
#
# ------------

# ------------
# Stage 2 : Build the application
#
#
FROM buildenv as appbuild
ARG APPLICATION_NAME
ARG VERSION

#
# Copy the source code.
# This layer is recreated only when there are actual source chnages
#
COPY ./src /usr/src/app/src

#
# Install the application
#
RUN ./gradlew clean bootJar
RUN ls -ltr /usr/src/app/build/libs

#
# ------------

# ------------
# Stage 3 : Application container
#
FROM openjdk:8-jdk-alpine as application
ARG APPLICATION_NAME
ARG VERSION

#
# bake this in to a build container layer ?
#
#COPY ./config /app/config

#
# copy the generated application distribution
#
COPY --from=appbuild /usr/src/app/build/libs/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar

EXPOSE 8080
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar
#
# ------------
