#User Service
[![wercker status](https://app.wercker.com/status/f59f625d8e8d9c33c00378517e1b26bb/s/ "wercker status")](https://app.wercker.com/project/byKey/f59f625d8e8d9c33c00378517e1b26bb)


This service covers user account storage, to include cards and addresses

>## API Spec

Checkout the API Spec [here](https://mushop.docs.apiary.io)

>## Build

### Using Go natively

```bash
go build -mod=vendor
```

### Using Docker Compose

```bash
docker-compose build
```

>## Test

```bash
go test -v ./...
```

>## Run

### Using Docker Compose
```bash
docker-compose up
```

>## Check

```bash
curl http://localhost:8080/health
```

>## Use

Test user account passwords can be found in the comments in `users-db-test/scripts/customer-insert.js`

### Customers

```bash
curl http://localhost:8080/customers
```

### Cards
```bash
curl http://localhost:8080/cards
```

### Addresses

```bash
curl http://localhost:8080/addresses
```

### Login
```bash
curl http://localhost:8080/login
```

### Register

```bash
curl http://localhost:8080/register
```

## Push

```bash
make dockertravisbuild
```

## Test Zipkin

To test with Zipkin

```
make
docker-compose -f docker-compose-zipkin.yml build
docker-compose -f docker-compose-zipkin.yml up
```
It takes about 10 seconds to seed data

you should see it at:
[http://localhost:9411/](http://localhost:9411)

be sure to hit the "Find Traces" button.  You may need to reload the page.

when done you can run:
```
docker-compose -f docker-compose-zipkin.yml down
```
