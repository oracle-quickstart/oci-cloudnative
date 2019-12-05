##### Application Metadata
ARG APPLICATION_NAME="carts"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Build the application using Maven
# 
FROM maven:3.6-jdk-8 as appbuild

# Get SODA Java
ADD https://github.com/oracle/soda-for-java/releases/download/v1.1.0/orajsoda-1.1.0.jar /tmp/orajsoda-1.1.0.jar 

RUN mvn install:install-file \
  -Dfile=/tmp/orajsoda-1.1.0.jar \
  -DgroupId=com.oracle.database.soda \
  -DartifactId=soda \
  -Dversion=1.1.0 \
  -Dpackaging=jar

# Create source folder
RUN mkdir -p /usr/src/app
COPY src     /usr/src/app/src
COPY pom.xml /usr/src/app/
WORKDIR      /usr/src/app/

RUN mvn package

# ------------
# Stage 2 : Application container
#
FROM openjdk:8-jre-slim
ARG APPLICATION_NAME
ARG VERSION

COPY ./config /app/config
COPY --from=appbuild /usr/src/app/target/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar
COPY --from=appbuild /usr/src/app/target/libs /app/libs
EXPOSE 80
WORKDIR /app

ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}

ENTRYPOINT java $JAVA_OPTS -Dserver.port=80 -jar /app/${APPLICATION_NAME}-${VERSION}.jar
