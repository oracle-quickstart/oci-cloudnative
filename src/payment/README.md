# Payment

[![Go Report Card](https://goreportcard.com/badge/github.com/oracle-quickstart/oci-cloudnative/tree/master/src/payment)](https://goreportcard.com/report/github.com/oracle-quickstart/oci-cloudnative/tree/master/src/payment)

A microservices demo service that provides payment services.

## Run Payment Service APIs on postman

[![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_payment]

## API Spec

Checkout the API Spec [here](https://mushop.docs.apiary.io)

## Build

### Using native Go tools

In order to build the project locally you need to make sure that the repository directory is located in the correct
$GOPATH directory: $GOPATH/src/github.com/oracle-quickstart/oci-cloudnative/src/payment/. Once that is in place you can build by running:

```shell
cd $GOPATH/src/github.com/oracle-quickstart/oci-cloudnative/src/payment/
go build -o payment
```

The result is a binary named `payment`, in the current directory.

#### Building with Docker Compose

`docker-compose build`

## Run

### Using Go native

If you followed to Go build instructions, you should have a "payment" binary in $GOPATH/src/github.com/oracle-quickstart/oci-cloudnative/src/payment/cmd/paymentsvc/.
To run it use:

```shell
./payment
ts=2021-05-11T05:57:44.8421733Z caller=main.go:81 transport=HTTP port=8080
```

### Using Docker Compose

If you used Docker Compose to build the payment project, the result should be a Docker image called `mushop/payment`.
To run it use:

```shell
docker-compose up
```

You can now access the service via `http://localhost:8082`

## Check

You can check the health of the service by doing a GET request to the health endpoint:

```shell
curl http://localhost:8082/health
{"health":[{"service":"payment","status":"OK","time":"2021-05-11 05:57:51.581619 +0000 UTC m=+6.744404101"}]}
```

## Use

You can authorize a payment by POSTing to the paymentAuth endpoint:

```shell
curl -H "Content-Type: application/json" -X POST -d'{"Amount":40}'  http://localhost:8082/paymentAuth
{"authorised":true}
```

[postman_button_payment]: https://god.gw.postman.com/run-collection/29850-cd57303a-f3df-4a22-8e18-09cd2218d94a?action=collection%2Ffork&collection-url=entityId%3D29850-cd57303a-f3df-4a22-8e18-09cd2218d94a%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
