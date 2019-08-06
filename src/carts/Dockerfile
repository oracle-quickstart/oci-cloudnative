ARG APPLICATION_NAME="carts"
ARG VERSION="0.0.1-SNAPSHOT"
##### Oracle Instant Client version
ARG clientVersion=19.3

# ------------
# Stage 1 : Setting up the build environment
# the base image used is a maven repo image with JDBC drivers pre-populated. 
# 
# 
FROM oraclelinux:7-slim as buildenv
ARG clientVersion
RUN yum update -y && \
  yum -y install java-1.8.0-openjdk-devel && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${clientVersion}-jdbc && \
  yum clean all && \
  rm -rf /var/cache/yum
ENV JAVA_HOME /usr/lib/jvm/java-openjdk
# 
# Maven crazy stuff
# 
ARG USER_HOME_DIR="/root"
ARG MAVEN_VERSION=3.3.9
RUN mkdir -p /usr/share/maven && \
curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Setup Oracle libraries
# JDBC
ARG JDBC_GROUP_ID="com.oracle.jdbc"
ARG JDBC_DRIVER_ARTIFACT_ID="ojdbc8"
ARG JDBC_DRIVER_ARTIFACT_VERSION="19.3.0.0"
ARG JDBC_UCP_ARTIFACT_ID="ojdbc8"
ARG JDBC_UCP_ARTIFACT_VERSION="19.3.0.0"

## Install dependencies to the local mavenrepo
RUN mvn install:install-file -Dfile=/usr/lib/oracle/${clientVersion}/client64/lib/ojdbc8.jar -DgroupId=${JDBC_GROUP_ID} -DartifactId=${JDBC_DRIVER_ARTIFACT_ID} -Dversion=${JDBC_DRIVER_ARTIFACT_VERSION} -Dpackaging=jar

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
FROM oraclelinux:7-slim as application
ARG APPLICATION_NAME
ARG VERSION
ARG clientVersion
RUN yum update -y && \
  yum -y install java-1.8.0-openjdk-devel && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${clientVersion}-jdbc && \
  yum clean all && \
  rm -rf /var/cache/yum
ENV JAVA_HOME /usr/lib/jvm/java-openjdk
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

