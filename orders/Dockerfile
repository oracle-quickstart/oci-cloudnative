ARG APPLICATION_NAME="orders"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setting up the build environment
# the base image used is a maven repo image with JDBC drivers pre-populated. 
# 
# 
FROM phx.ocir.io/intvravipati/jeevan/mvn-jdbc:latest as buildenv

# 
# create source folder
# 
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#
# copy buildscript and cache all dependencies
# only the build.gradle, and the gradle warpper are required.
# 
COPY build.gradle /usr/src/app
COPY settings.gradle /usr/src/app
COPY gradle /usr/src/app/gradle
COPY gradlew /usr/src/app
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
FROM openjdk:8-jdk-alpine as application
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

EXPOSE 8080
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}
ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar
#
# ------------

