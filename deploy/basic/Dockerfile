#
# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Oracle Instant Client version
ARG oracleClientVersion=19.10

###############################
#    ----- STOREFRONT -----   #
#    Build stage (node/npm)   #
###############################
FROM --platform=${BUILDPLATFORM:-linux/amd64} node:16-alpine as storefront-builder

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
WORKDIR /tmp
COPY src/storefront/package.json /tmp/package.json
COPY src/storefront/package-lock.json /tmp/package-lock.json
RUN npm ci
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
FROM --platform=${TARGETPLATFORM:-linux/amd64} node:16-alpine as api-builder

WORKDIR /app/api
COPY src/api/. .

# Prune (prom-client removed to fix KBs for orm stack)
RUN rm -rf test scripts && \
    rm package-lock.json && \
    npm uninstall prom-client && \
    npm uninstall connect-redis && \
    npm prune --production

#    ----- API Gateway -----  #

###############################
#  ----- Image Assets -----   #
###############################
FROM --platform=${BUILDPLATFORM:-linux/amd64} node:16-alpine as assets-builder

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

COPY src/assets/package.json /tmp/package.json
COPY src/assets/package-lock.json /tmp/package-lock.json
RUN cd /tmp && npm ci
RUN mkdir -p /app/assets && cp -a /tmp/node_modules /app/assets/
RUN rm -rf /tmp/node_modules

WORKDIR /app/assets
COPY src/assets/. .
RUN rm -rf /app/assets/hero

RUN npm run build
RUN rm -rf node_modules products hero *.md
#  ----- Image Assets -----   #

###############################
#    ------ Catalogue ------  #
#    Build stage (Go Build)   #
#     Architecture: amd64     #
###############################

# ##### Go Builder image
FROM --platform=linux/amd64 golang:1.17 AS catalogue-builder-amd64

WORKDIR /go/src/mushop/catalogue

# # Catalogue Go Source
COPY src/catalogue/cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY src/catalogue/*.go ./
COPY src/catalogue/go.mod ./
COPY src/catalogue/go.sum ./

# # Get Go Modules
RUN go get .
RUN go get mushop/catalogue/cmd/cataloguesvc

# # Build Catalogue service
RUN GO111MODULE=on GOARCH=amd64 GOOS=linux \
  go build -a \
  -ldflags="-s -w" \
  -installsuffix cgo \
  -o /catalogue mushop/catalogue/cmd/cataloguesvc

#  --- Catalogue - amd64 ---  #

###############################
#    ------ Catalogue ------  #
#    Build stage (Go Build)   #
#     Architecture: arm64     #
###############################

# ##### Go Builder image
FROM --platform=linux/arm64 golang:1.17 AS catalogue-builder-arm64

WORKDIR /go/src/mushop/catalogue

# # Catalogue Go Source
COPY src/catalogue/cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY src/catalogue/*.go ./
COPY src/catalogue/go.mod ./
COPY src/catalogue/go.sum ./

# # Get Go Modules
RUN go get .
RUN go get mushop/catalogue/cmd/cataloguesvc

# # Build Catalogue service
RUN GO111MODULE=on GOARCH=arm64 GOOS=linux \
  go build -a \
  -ldflags="-s -w" \
  -installsuffix cgo \
  -o /catalogue mushop/catalogue/cmd/cataloguesvc

#  --- Catalogue - arm64 ---  #

###############################
#  ----- Runtime Image -----  #
#   runtime app and stack     #
###############################

# Base image with Oracle Instant Client Basic Lite
FROM --platform=${TARGETPLATFORM:-linux/amd64} oraclelinux:7-slim
ARG oracleClientVersion
RUN yum clean metadata && \
  yum update -y && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum-config-manager --enable ol7_latest && \
  yum -y install oracle-instantclient${oracleClientVersion}-basiclite && \
  yum -y install zip && \
  yum -y install oracle-nodejs-release-el7 && \
  yum -y install nodejs && \
  yum -y install httpd && \
  yum -y install oracle-epel-release-el7 && \
  yum -y install upx && \
  yum clean all && \
  rm -rf /var/cache/yum

COPY deploy/basic/terraform/scripts/httpd.conf /etc/httpd/conf/
COPY deploy/basic/terraform/scripts/docker_entrypoint.sh /
RUN chmod +x /docker_entrypoint.sh

WORKDIR /

# Copy Services apps
COPY --from=storefront-builder /app/storefront/build /app/storefront
COPY --from=api-builder /app/api /app/api
COPY --from=catalogue-builder-amd64 /catalogue /app/catalogue/catalogue-amd64
COPY --from=catalogue-builder-arm64 /catalogue /app/catalogue/catalogue-arm64
COPY src/catalogue/VERSION /app/catalogue/

# UPX catalogues
RUN upx --best --lzma /app/catalogue/catalogue-amd64
RUN upx --best --lzma /app/catalogue/catalogue-arm64

# Create zip package of the Apps and local images
RUN mkdir /package && tar cv /app | xz -3e > /package/mushop-basic.tar.xz

# Create ORM package
WORKDIR /basic
COPY deploy/basic/terraform/VERSION /basic/
COPY deploy/basic/terraform/*.tf /basic/
COPY deploy/basic/terraform/*.tfvars.example /basic/
COPY deploy/basic/terraform/schema.yaml /basic/
COPY deploy/basic/terraform/scripts /basic/scripts
COPY src/catalogue/dbdata/atp_mushop_catalogue.sql /basic/scripts/
COPY --from=assets-builder /app/assets/dist/ /basic/images/
RUN cp /package/mushop-basic.tar.xz /basic/scripts/
RUN zip -9 -r /package/mushop-basic-stack.zip .

VOLUME ["/usr/lib/oracle/${oracleClientVersion}/client64/lib/network/admin/"]
VOLUME ["/transfer/"]
ENTRYPOINT ["/docker_entrypoint.sh"]
EXPOSE 80
EXPOSE 3000
EXPOSE 3005

#    ----- Runtime Image ------  #
