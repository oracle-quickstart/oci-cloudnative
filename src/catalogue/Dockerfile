FROM golang:1.12 AS go-builder
WORKDIR /go/src/mushop/catalogue

COPY images/ images/
COPY cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY *.go /go/src/mushop/catalogue/
COPY go.mod /go/src/mushop/catalogue/

RUN GO111MODULE=on GOARCH=amd64 GOOS=linux \
  go build -a \
  -installsuffix cgo \
  -o /app mushop/catalogue/cmd/cataloguesvc

FROM oraclelinux:7-slim AS base
ARG release=19
ARG update=3
RUN  yum -y install oracle-release-el7 && yum-config-manager --enable ol7_oracle_instantclient && \
  yum -y install oracle-instantclient${release}.${update}-basic oracle-instantclient${release}.${update}-devel oracle-instantclient${release}.${update}-sqlplus && \
  rm -rf /var/cache/yum

FROM base
WORKDIR /
COPY --from=go-builder /app /app
COPY images/ /images/

RUN	setcap 'cap_net_bind_service=+ep' /app

CMD ["/app", "-port=80"]
EXPOSE 80