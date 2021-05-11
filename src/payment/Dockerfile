#
# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##### Go Builder image
FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.16 AS go-builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/mushop/payment
COPY cmd/*.go cmd/
COPY *.go .
COPY go.mod .
COPY go.sum .

RUN GO111MODULE=on GOARCH=${TARGETARCH} CGO_ENABLED=0 GOOS=${TARGETOS} \
    go build -a \
    -installsuffix cgo \
    -o /payment cmd/main.go

FROM alpine:3.13
COPY --from=go-builder /payment /
COPY --from=go-builder /go/src/mushop/payment/go.mod /
CMD ["/payment", "-port=80"]