#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Oracle Instant Client version
ARG clientVersion=21
ARG ARCH=amd64
ARG OS=linux

##### Go Builder image
FROM golang:1.15 AS go-builder
WORKDIR /go/src/mushop/catalogue

# Support for Offline local image. Online image on OCI Object Storage
COPY images/ images/

# Catalogue Go Source
COPY cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY *.go /go/src/mushop/catalogue/
COPY go.mod /go/src/mushop/catalogue/

# Build Catalogue service
RUN GOARCH=${ARCH} GOOS=${OS} \
  go build -a \
  -o /catalogue mushop/catalogue/cmd/cataloguesvc

##### Base image with Oracle Instant Client Basic Lite
FROM oraclelinux:8-slim AS base
ARG clientVersion
RUN microdnf update && \
    microdnf install oracle-instantclient-release-el8 && \
    microdnf install oracle-instantclient-basiclite && \
    microdnf clean all && \
    rm -rf /var/cache/dnf && \
    rm -rf /var/cache/yum

##### Catalogue Service Image
FROM base
ARG clientVersion
WORKDIR /
COPY --from=go-builder /catalogue /catalogue
COPY images/ /images/

RUN	setcap 'cap_net_bind_service=+ep' /catalogue

VOLUME ["/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/"]
## Workaround to support current implementation. Will go away when fix issue #138
RUN mkdir -p /usr/lib/oracle/19.3/client64/lib/network/ && \
    ln -sfF /usr/lib/oracle/${clientVersion}/client64/lib/network/admin/ /usr/lib/oracle/19.3/client64/lib/network/ 
VOLUME ["/usr/lib/oracle/19.3/client64/lib/network/admin/"]
## ##

CMD ["/catalogue", "-port=80"]
EXPOSE 80