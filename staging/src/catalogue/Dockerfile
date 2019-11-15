#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Oracle Instant Client version
ARG clientVersion=19.3

##### Go Builder image
FROM golang:1.13 AS go-builder
WORKDIR /go/src/mushop/catalogue

# Support for Offline local image. Online image on OCI Object Storage
COPY images/ images/

# Catalogue Go Source
COPY cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY *.go /go/src/mushop/catalogue/
COPY go.mod /go/src/mushop/catalogue/

# Build Catalogue service
RUN GO111MODULE=on GOARCH=amd64 GOOS=linux \
  go build -a \
  -installsuffix cgo \
  -o /app mushop/catalogue/cmd/cataloguesvc

##### Base image with Oracle Instant Client Basic Lite
FROM oraclelinux:7-slim AS base
ARG clientVersion
RUN yum update -y && \
  yum -y install oracle-release-el7 && \
  yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${clientVersion}-basiclite && \
  yum clean all && \
  rm -rf /var/cache/yum

##### Catalogue Service Image
FROM base
ARG clientVersion
WORKDIR /
COPY --from=go-builder /app /app
COPY images/ /images/

RUN	setcap 'cap_net_bind_service=+ep' /app

VOLUME ["/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/"]
CMD ["/app", "-port=80"]
EXPOSE 80