# MuShop User Service

Represents a microservice for customer information, authentication, and metadata

## Prepare Environment

Before running the application, it is necessary to prepare the database schema.
This requires an instance of Autonomous Transaction Processing with credentials

1. Extract ATP `Wallet_*.zip` contents into the project directory.
2. Prepare the applicaion schema as `admin`:

  ```text
  docker-compose run \
    -e OADB_USER=admin \
    -e OADB_PW=${OADB_ADMIN_PW} \
    -e OADB_SCHEMA_USER_PW=${OADB_SCHEMA_USER_PW} \
    user npm run build:schema
  ```

3. Synchronize the schema with the ORM model:

  ```text
  docker-compose run user npm run build:orm
  ```

## Develop

```text
docker-compose up
```

## Build

```text
docker-compose build
```
