FROM golang:1.12 AS go-builder
WORKDIR /go/src/mushop/catalogue
#COPY . /go/src/mushop/catalogue
COPY images/ images/
COPY cmd/cataloguesvc/*.go cmd/cataloguesvc/
COPY *.go /go/src/mushop/catalogue/
COPY go.mod /go/src/mushop/catalogue/
#RUN GO111MODULE=on go get -u
#RUN go list
RUN GO111MODULE=on GOARCH=amd64 GOOS=linux go build -a -installsuffix cgo -o /app mushop/catalogue/cmd/cataloguesvc

FROM debian:stretch-slim AS base
COPY installs/instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip /installs/
COPY Wallet_Creds/. /usr/lib/oracle/instantclient_19_3/network/admin/.
ENV LD_LIBRARY_PATH=/usr/lib/oracle/instantclient_19_3:$LD_LIBRARY_PATH
ENV PATH=/usr/lib/oracle/instantclient_19_3:$PATH
WORKDIR /usr/lib/oracle
RUN apt-get update && apt-get install -y \
    libaio1 \
		libcap2-bin \
    zip \
    && rm -rf /var/lib/apt/lists/* \
    && unzip /installs/instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip -d /usr/lib/oracle \
    && rm -rf /installs 

FROM base
WORKDIR /
COPY --from=go-builder /app /app
COPY images/ /images/

RUN	setcap 'cap_net_bind_service=+ep' /app

CMD ["/app", "-port=80"]
EXPOSE 80