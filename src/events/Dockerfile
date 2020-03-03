#
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
FROM golang:1.13-alpine AS go-builder
RUN apk add --no-cache ca-certificates git
WORKDIR /src
COPY *.go ./
COPY go.* ./
COPY cmd cmd

# Build service
RUN GO111MODULE=on GOARCH=amd64 CGO_ENABLED=0 GOOS=linux \
    go build -a \
    -installsuffix cgo \
    -o /app cmd/main.go

# Create runtime
FROM oraclelinux:7-slim

ENV	SERVICE_USER=muuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mugroup \
	SERVICE_GID=10001

RUN groupadd --gid ${SERVICE_GID} --system ${SERVICE_GROUP} && \
    useradd --uid ${SERVICE_UID} --system --gid ${SERVICE_GID} ${SERVICE_USER}

WORKDIR /
EXPOSE 80
COPY --from=go-builder /app /app

RUN	chmod +x /app && \
	chown -R ${SERVICE_USER}:${SERVICE_GROUP} /app && \
	setcap 'cap_net_bind_service=+ep' /app

USER ${SERVICE_USER}

CMD ["/app", "-port=80"]