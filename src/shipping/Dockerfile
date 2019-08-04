ARG APPLICATION_NAME="shipping"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setting up the build environment
# 
FROM phx.ocir.io/intvravipati/jeevan/mvn-jdbc:latest as buildenv
# ----

# Setup OCI libraries
ARG GROUP_ID="com.oracle.oci"
ARG ARTIFACT_ID="oci-java-sdk"
ARG ARTIFACT_VERSION="1.5.16"

## Install dependencies to the local repo and cleanup
ADD https://github.com/oracle/oci-java-sdk/releases/download/v${ARTIFACT_VERSION}/${ARTIFACT_ID}.zip /root/
RUN cd /root && unzip -j ${ARTIFACT_ID}.zip shaded/lib/${ARTIFACT_ID}-full-shaded-${ARTIFACT_VERSION}.jar
RUN mvn install:install-file -Dfile=/root/${ARTIFACT_ID}-full-shaded-${ARTIFACT_VERSION}.jar -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${ARTIFACT_VERSION} -Dpackaging=jar &&  rm /root/*.jar

#
# create source folder
#
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#
# Get Gradle.
#
COPY settings.gradle /usr/src/app
COPY gradle /usr/src/app/gradle
COPY gradlew /usr/src/app
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
# copy the generated application distribution
#
COPY --from=appbuild /usr/src/app/build/libs/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar

EXPOSE 80
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar
#
# ------------
