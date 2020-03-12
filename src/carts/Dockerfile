##### Application Metadata
ARG APPLICATION_NAME="carts"
ARG VERSION="1.1.0-SNAPSHOT"
ARG SODA_VERSION="1.1.0"

# ------------
# Stage 1 : Build the application using Maven
# 
FROM maven:3.6-jdk-8 as appbuild

ARG SODA_VERSION

# Get SODA Java
ADD https://github.com/oracle/soda-for-java/releases/download/v${SODA_VERSION}/orajsoda-${SODA_VERSION}.jar /tmp/orajsoda-${SODA_VERSION}.jar

RUN mvn install:install-file -Dfile=/tmp/orajsoda-${SODA_VERSION}.jar -DgroupId=com.oracle.database.soda -DartifactId=soda -Dversion=${SODA_VERSION} -Dpackaging=jar

# Create source folder
RUN mkdir -p /usr/src/app
COPY pom.xml /usr/src/app/
WORKDIR      /usr/src/app/
RUN mvn dependency:go-offline -B

COPY src     /usr/src/app/src
RUN mvn package

# ------------
# Stage 2 : Application container
#
FROM openjdk:8-jre-slim
ARG APPLICATION_NAME
ARG VERSION

COPY --from=appbuild /usr/src/app/target/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar
COPY --from=appbuild /usr/src/app/target/libs /app/libs
EXPOSE 80
WORKDIR /app

ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENV TNS_ADMIN=/usr/lib/oracle/19.3/client64/lib/network/admin/

ENTRYPOINT java $JAVA_OPTS -Dserver.port=80 -jar /app/${APPLICATION_NAME}-${VERSION}.jar
