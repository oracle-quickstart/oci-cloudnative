# Using Catalogue service with docker compose

## Build local image

```shell
docker compose build
```

## Download ATP DB wallet

- Go to <https://cloud.oracle.com/db/adb>
- Select and click on your MuShop Db
- Click DB Connection and download the Instance Wallet
- Extract the contents to the docker folder
- Rename the Wallet folder to `Wallet_Creds`

## Run catalogue service

```shell
docker compose up
```

Note: If want to run on background, use `docker compose up -d`

## Check if service is health

```shell
curl http://localhost:8080/health
```

## Test Service

```shell
curl http://localhost:8080/catalogue
```

## Stop service and remove resources

```shell
docker compose down
```

## TRACING: Run catalogue service with Zipkin service

```shell
docker compose -f docker-compose-zipkin.yml up
```

Access Zipkin ui here: <http://localhost:9411/zipkin/>
