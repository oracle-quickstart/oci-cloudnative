# Payment
[![Build Status](https://travis-ci.org/microservices-demo/payment.svg?branch=master)](https://travis-ci.org/microservices-demo/payment)
[![Coverage Status](https://coveralls.io/repos/github/microservices-demo/payment/badge.svg?branch=master)](https://coveralls.io/github/microservices-demo/payment?branch=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/microservices-demo/user)](https://goreportcard.com/report/github.com/microservices-demo/user)
[![](https://images.microbadger.com/badges/image/weaveworksdemos/payment.svg)](http://microbadger.com/images/weaveworksdemos/payment "Get your own image badge on microbadger.com")

A microservices-demo service that provides payment services.
This build is built, tested and released by travis.

## Bugs, Feature Requests and Contributing
We'd love to see community contributions. We like to keep it simple and use Github issues to track bugs and feature requests and pull requests to manage contributions.

## API Spec

Checkout the API Spec [here](http://microservices-demo.github.io/api/index?url=https://raw.githubusercontent.com/microservices-demo/payment/master/api-spec/payment.json)

## Build

#### Dependencies
```
cd $GOPATH/src/github.com/microservices-demo/payment/
go get -u github.com/FiloSottile/gvt
gvt restore
```

#### Using native Go tools
In order to build the project locally you need to make sure that the repository directory is located in the correct
$GOPATH directory: $GOPATH/src/github.com/microservices-demo/payment/. Once that is in place you can build by running:

```
cd $GOPATH/src/github.com/microservices-demo/payment/paymentsvc/
go build -o payment
```

The result is a binary named `payment`, in the current directory.

#### Using Docker Compose
`docker-compose build`

## Test
`COMMIT=test make test`

## Run 

#### Using Go native

If you followed to Go build instructions, you should have a "payment" binary in $GOPATH/src/github.com/microservices-demo/payment/cmd/paymentsvc/.
To run it use:
```
./payment
ts=2016-12-14T11:48:58Z caller=main.go:29 transport=HTTP port=8080
```

#### Using Docker Compose

If you used Docker Compose to build the payment project, the result should be a Docker image called `weaveworksdemos/payment`.
To run it use:
```
docker-compose up
```

You can now access the service via http://localhost:8082

## Check

You can check the health of the service by doing a GET request to the health endpoint:

```
curl http://localhost:8082/health
{"health":[{"service":"payment","status":"OK","time":"2016-12-14 12:22:04.716316395 +0000 UTC"}]}
```

## Use

You can authorise a payment by POSTing to the paymentAuth endpoint:

```
curl -H "Content-Type: application/json" -X POST -d'{"Amount":40}'  http://localhost:8082/paymentAuth
{"authorised":true}
```

## Push
`GROUP=weaveworksdemos COMMIT=test ./scripts/push.sh`
