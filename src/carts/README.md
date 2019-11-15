[![Build Status](https://travis-ci.org/microservices-demo/carts.svg?branch=master)](https://travis-ci.org/microservices-demo/carts) [![Coverage Status](https://coveralls.io/repos/github/microservices-demo/carts/badge.svg?branch=master)](https://coveralls.io/github/microservices-demo/carts?branch=master)
[![](https://images.microbadger.com/badges/image/weaveworksdemos/cart.svg)](http://microbadger.com/images/weaveworksdemos/cart "Get your own image badge on microbadger.com")
# cart
A microservices-demo service that provides shopping carts for users.

This build is built, tested and released by travis.

# API Spec

Checkout the API Spec [here](http://microservices-demo.github.io/api/index?url=https://raw.githubusercontent.com/microservices-demo/carts/master/api-spec/cart.json)

# Build

## Java

`mvn -DskipTests package`

## Docker

`GROUP=aurademos/durhamdenim COMMIT=test ./scripts/build.sh`

# Test

`./test/test.sh < python testing file >`. For example: `./test/test.sh unit.py`

# Run

`mvn spring-boot:run`

# Check

`curl http://localhost:8081/health`

# Use

`curl http://localhost:8081`

# Push

`GROUP=aurademos/durhamdenim COMMIT=test ./scripts/push.sh`
