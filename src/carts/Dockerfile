ARG APPLICATION_NAME="carts"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setting up the build environment
# the base image used is a maven repo image with JDBC drivers pre-populated. 
# 
# 
FROM oraclelinux:7-slim as buildenv

ARG JDBC_GROUP_ID="com.oracle.jdbc"
ARG JDBC_DRIVER_ARTIFACT_ID="ojdbc8"
##### Oracle Instant Client version
ARG JDBC_DRIVER_VERSION="19.3"
##### Gradle version
ARG GRADLE_VERSION=5.5.1

ENV JAVA_HOME /usr/lib/jvm/java-openjdk
ENV GRADLE_HOME /opt/gradle

RUN yum update -y && \
  yum -y install unzip && \
  yum -y install java-1.8.0-openjdk-devel && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --add-repo http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo && \
  yum-config-manager --enable epel-apache-maven && \
  yum install -y apache-maven && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${JDBC_DRIVER_VERSION}-jdbc && \
  yum clean all && \
  rm -rf /var/cache/yum

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
RUN gradle wrapper --gradle-version 5.5.1 --distribution-type all
RUN ./gradlew --refresh-dependencies
#
# copy buildscript and cache all dependencies
# 
COPY build.gradle /usr/src/app
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
COPY src /usr/src/app/src

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

