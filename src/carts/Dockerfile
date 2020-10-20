##### Application Metadata
ARG APPLICATION_NAME="carts"
ARG VERSION="1.1.0-SNAPSHOT"
ARG clientVersion=19.3

# ------------
# Stage 1 : Build the application using Maven
# 
FROM maven:3.6-jdk-11 as appbuild

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
FROM openjdk:11-jre-slim
ARG APPLICATION_NAME
ARG VERSION
ARG clientVersion

COPY --from=appbuild /usr/src/app/target/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar
COPY --from=appbuild /usr/src/app/target/libs /app/libs
EXPOSE 80
WORKDIR /app

ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENV TNS_ADMIN=/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/

ENTRYPOINT java $JAVA_OPTS  -jar /app/${APPLICATION_NAME}-${VERSION}.jar
