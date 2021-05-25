#
# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Go Builder image
FROM --platform=${TARGETPLATFORM:-linux/amd64} golang:1.16 AS go-builder

ARG TARGETOS
ARG TARGETARCH

# Payment Go Source
WORKDIR /go/src/mushop/payment
COPY cmd/*.go cmd/
COPY *.go .
COPY go.mod .
COPY go.sum .

# Build Payment service
RUN GOARCH=${TARGETARCH:-amd64} CGO_ENABLED=0 GOOS=${TARGETOS:-linux} \
    go build -a \
    -installsuffix cgo \
    -o /payment cmd/main.go

##### Payment Service Image
FROM --platform=${TARGETPLATFORM:-linux/amd64} oraclelinux:8-slim

ARG TARGETPLATFORM
ARG LICENSE

RUN groupadd -r app -g 1000 && \
    useradd -u 1000 -r -g app -m -d /app -s /sbin/nologin -c "App user" app && \
    chmod 755 /app

WORKDIR /app
USER app

COPY --from=go-builder /payment /app/
CMD ["/app/payment", "-port=8080"]
EXPOSE 8080

LABEL org.opencontainers.image.title="payment" \
    org.opencontainers.image.architecture="${TARGETPLATFORM}"
