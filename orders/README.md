[![Build Status](https://travis-ci.org/microservices-demo/orders.svg?branch=master)](https://travis-ci.org/microservices-demo/orders) [![Coverage Status](https://coveralls.io/repos/github/microservices-demo/orders/badge.svg?branch=master)](https://coveralls.io/github/microservices-demo/orders?branch=master)
[![](https://images.microbadger.com/badges/image/weaveworksdemos/orders.svg)](http://microbadger.com/images/weaveworksdemos/orders "Get your own image badge on microbadger.com")

# orders
A microservices-demo service that provides ordering capabilities.

This build is built, tested and released by travis.

# API Spec

Checkout the API Spec [here](http://microservices-demo.github.io/api/index?url=https://raw.githubusercontent.com/microservices-demo/orders/master/api-spec/orders.json)

# Build

## Jar
`mvn -DskipTests package`

## Docker
`GROUP=aurademos/durhamdenim COMMIT=test ./scripts/build.sh`

# Test
`./test/test.sh < python testing file >`. For example: `./test/test.sh unit.py`

# Run
`mvn spring-boot:run`

# Use
`curl http://localhost:8082`

# Push
`GROUP=aurademos/durhamdenim COMMIT=test ./scripts/push.sh`
