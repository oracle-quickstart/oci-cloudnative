FROM golang:1.12-alpine AS go-builder
RUN apk add --no-cache ca-certificates git
WORKDIR /src
COPY . .

RUN GO111MODULE=on GOARCH=amd64 CGO_ENABLED=0 GOOS=linux \
    go build -a \
    -installsuffix cgo \
    -o /payment cmd/main.go

FROM alpine:3.4
COPY --from=go-builder /payment /
CMD ["/payment", "-port=80"]