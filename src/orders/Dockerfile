##### Application Metadata
ARG APPLICATION_NAME="orders"
ARG VERSION="0.0.1-SNAPSHOT"
##### Oracle Instant Client version
ARG JDBC_DRIVER_VERSION="19.3"

# ------------
# Stage 1 : Download Oracle JDBC drivers. 
# 
# 
FROM oraclelinux:7-slim as oracleinstantclientjdbc

ARG JDBC_DRIVER_VERSION

RUN yum update -y && \
    yum -y install oracle-release-el7 && \
    yum-config-manager --enable ol7_oracle_instantclient && \
    yum -y install oracle-instantclient${JDBC_DRIVER_VERSION}-jdbc && \
    yum clean all && \
    rm -rf /var/cache/yum

#
# ------------

# ------------
# Stage 2 : Setting up the build environment with maven and gradle
# 
# 
FROM maven:3.6-jdk-8 as buildenv

ARG JDBC_DRIVER_VERSION
ARG JDBC_GROUP_ID="com.oracle.jdbc"
ARG JDBC_DRIVER_ARTIFACT_ID="ojdbc8"
ARG GRADLE_VERSION=5.5.1

ENV GRADLE_HOME /opt/gradle

COPY --from=oracleinstantclientjdbc /usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar /usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar

RUN mvn install:install-file -Dfile=/usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar -DgroupId=${JDBC_GROUP_ID} -DartifactId=${JDBC_DRIVER_ARTIFACT_ID} -Dversion=${JDBC_DRIVER_VERSION} -Dpackaging=jar

# 
# create source folder
# 
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# 
# Get Gradle.
#
ADD https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip /tmp/gradle.zip
RUN echo "Installing Gradle" && \
    unzip /tmp/gradle.zip && \
    rm /tmp/gradle.zip && \
    mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" && \
    ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle && \
    echo "Testing Gradle installation" && \
    gradle --version

COPY settings.gradle /usr/src/app
RUN gradle --refresh-dependencies
#
# copy buildscript and cache all dependencies
# 
COPY build.gradle /usr/src/app
RUN gradle --refresh-dependencies
#
# ------------

# ------------
# Stage 3 : Build the application
#
#
FROM buildenv as appbuild
ARG APPLICATION_NAME
ARG VERSION

#
# Copy the source code. 
# This layer is recreated only when there are actual source chnages 
#
COPY src /usr/src/app/src

#
# Install the application
#
RUN gradle clean bootJar 
RUN ls -ltr /usr/src/app/build/libs

#
# ------------

# ------------
# Stage 4 : Application container
#
FROM openjdk:8-jre-slim
ARG APPLICATION_NAME
ARG VERSION
#
# bake this in to a build container layer ?
# 
COPY ./config /app/config

#
# copy the generated application distribution
# 
COPY --from=appbuild /usr/src/app/build/libs/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar

EXPOSE 80
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar --port=80
#
# ------------

