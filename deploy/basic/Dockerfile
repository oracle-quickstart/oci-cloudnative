#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Oracle Instant Client version
ARG oracleClientVersion=19.3

# Node version
ARG nodeVersion=10

###############################
#    ----- STOREFRONT -----   #
#    Build stage (node/npm)   #
###############################
FROM node:10-alpine as storefront-builder

RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    bash \
    g++ \
    libtool \
    libc6-compat \
    libjpeg-turbo-dev \
    libpng-dev \
    make \
    nasm

RUN npm config set loglevel warn \
  && npm set progress=false

# install dependencies
COPY src/storefront/package.json /tmp/package.json
COPY src/storefront/package-lock.json /tmp/package-lock.json
RUN cd /tmp && npm ci
RUN mkdir -p /app/storefront && cp -a /tmp/node_modules /app/storefront/
RUN rm -rf /tmp/node_modules

# copy source and build
WORKDIR /app/storefront
COPY src/storefront/src src
COPY src/storefront/*.js* ./
COPY src/storefront/VERSION VERSION

ARG STATIC_ASSET_URL
ENV STATIC_ASSET_URL ${STATIC_ASSET_URL:-""}
ENV NODE_ENV "production"
RUN npm run build
#    ----- STOREFRONT -----   #

###############################
#    ----- API Gateway -----  #
#    Build stage (node/npm)   #
###############################
FROM node:10-alpine as api-builder

WORKDIR /app/api
COPY src/api/. .

# Prune
RUN rm -rf test scripts node_modules
#    ----- API Gateway -----  #

###############################
#    ------ Catalogue ------  #
#    Build stage (Go Build)   #
###############################

# ##### Go Builder image
FROM golang:1.13 AS catalogue-builder
WORKDIR /go/src/mushop/catalogue

# # Catalogue Go Source
COPY src/catalogue/cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY src/catalogue/*.go ./
COPY src/catalogue/go.mod ./

# # Build Catalogue service
RUN GO111MODULE=on GOARCH=amd64 GOOS=linux \
  go build -a \
  -ldflags="-s -w" \
  -installsuffix cgo \
  -o /catalogue mushop/catalogue/cmd/cataloguesvc

#    ------ Catalogue ------  #

###############################
#    ----- Base Image ------  #
#      Everything needed      #
###############################

# Base image with Oracle Instant Client Basic Lite
FROM oraclelinux:7-slim AS base
ARG oracleClientVersion
ARG nodeVersion
RUN yum update -y && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${oracleClientVersion}-basiclite && \
  yum install -y gcc-c++ make sudo zip && \
  curl -sL https://rpm.nodesource.com/setup_${nodeVersion}.x | sudo -E bash - && \
  yum -y install nodejs && \
  yum -y install httpd && \
  yum clean all && \
  rm -rf /var/cache/yum

COPY deploy/basic/httpd.conf /etc/httpd/conf/
COPY deploy/basic/entrypoint.sh /
RUN chmod +x /entrypoint.sh

#    ----- Base Image ------  #

###############################
#  ----- Runtime Image -----  #
#   runtime app and stack     #
###############################

# Runtime Image
FROM base
ARG oracleClientVersion
ARG nodeVersion
WORKDIR /
# Support for Offline local image. Online image on OCI Object Storage
COPY src/catalogue/images/ images/

# Copy Services apps
COPY --from=storefront-builder /app/storefront/build /app/storefront
COPY --from=api-builder /app/api /app/api
COPY --from=catalogue-builder /catalogue /app/catalogue/catalogue

# Create zip package of the Apps and local images
RUN mkdir /package && GZIP=-9 tar cvzf /package/mushop-basic.tar.gz /app /images

# Create ORM package
COPY deploy/basic/terraform /basic
COPY src/catalogue/dbdata/atp_mushop_catalogue.sql /basic/scripts
COPY deploy/basic/httpd.conf /basic/scripts
COPY deploy/basic/entrypoint.sh /basic/scripts
RUN cp /package/mushop-basic.tar.gz /basic/scripts && \
    cd /basic && zip -r /package/mushop-basic-stack.zip .

VOLUME ["/usr/lib/oracle/${oracleClientVersion}/client64/lib/network/admin/"]
VOLUME ["/transfer/"]
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80
EXPOSE 3000
EXPOSE 3005

#    ----- Base Image ------  #
