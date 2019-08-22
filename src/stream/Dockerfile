##### Application Metadata
ARG APPLICATION_NAME="stream"
ARG VERSION="0.0.1-SNAPSHOT"

# ------------
# Stage 1 : Setting up the build environment with maven and gradle
# 
# 
FROM maven:3.6-jdk-8 as buildenv

ARG JDBC_DRIVER_VERSION
ARG JDBC_GROUP_ID="com.oracle.jdbc"
ARG JDBC_DRIVER_ARTIFACT_ID="ojdbc8"
ARG GRADLE_VERSION=5.5.1

ENV GRADLE_HOME /opt/gradle

# COPY --from=oracleinstantclientjdbc /usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar /usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar
# RUN mvn install:install-file -Dfile=/usr/lib/oracle/${JDBC_DRIVER_VERSION}/client64/lib/ojdbc8.jar -DgroupId=${JDBC_GROUP_ID} -DartifactId=${JDBC_DRIVER_ARTIFACT_ID} -Dversion=${JDBC_DRIVER_VERSION} -Dpackaging=jar

# Setup OCI libraries
ARG GROUP_ID="com.oracle.oci"
ARG ARTIFACT_ID="oci-java-sdk"
ARG ARTIFACT_VERSION="1.5.16"

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

