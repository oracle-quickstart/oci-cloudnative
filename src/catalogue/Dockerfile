#
# Copyright (c) 2020-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Oracle Instant Client version
ARG clientVersion=19.10
# Using 19.10 for multi platform support. Will change to 21 as soon Arm64 is supported

##### Go Builder image
FROM --platform=${TARGETPLATFORM:-linux/amd64} golang:1.16 AS go-builder

ARG TARGETARCH
ARG TARGETOS

WORKDIR /go/src/mushop/catalogue

# Support for Offline local image. Online image on OCI Object Storage
COPY images/ images/

# Catalogue Go Source
COPY cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY *.go .
COPY go.mod .
COPY go.sum .

# Build Catalogue service
RUN GOARCH=${TARGETARCH:-amd64} GOOS=${TARGETOS:-linux} \
  go build -a \
  -o /catalogue mushop/catalogue/cmd/cataloguesvc

##### Catalogue Service Image with Oracle Instant Client Basic Lite
FROM --platform=${TARGETPLATFORM:-linux/amd64} oraclelinux:8-slim

ARG clientVersion
ARG TARGETPLATFORM

RUN microdnf update && \
    microdnf install oracle-release-el8 && \
    microdnf install oracle-instantclient${clientVersion}-basiclite && \
    microdnf clean all && \
    rm -rf /var/cache/dnf && \
    rm -rf /var/cache/yum

RUN groupadd -r app -g 687467 && \
    useradd -u $((1000 + $RANDOM)) -r -g app -m -d /app -s /sbin/nologin -c "App user" app && \
    chmod 755 /app && \
    chown -R app /usr/lib/oracle

WORKDIR /app
COPY --from=go-builder --chown=app:app /catalogue /app/
COPY --chown=app:app images/ /app/images/

VOLUME ["/usr/lib/oracle/${clientVersion}/client64/lib/network/admin/"]
## Workaround to support current implementation. Will go away when fix issue #138
VOLUME ["/usr/lib/oracle/19.3/client64/lib/network/admin/"]
## ##

USER app

CMD ["/app/catalogue", "-port=8080"]
EXPOSE 8080

LABEL org.opencontainers.image.title="catalogue" \
    org.opencontainers.image.architecture="${TARGETPLATFORM}"