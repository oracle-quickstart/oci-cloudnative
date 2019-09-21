# MuShop User Service

Represents a microservice for customer information, authentication, and metadata

## Technologies

The MuShop user service is written with TypeScript and leverages the following technologies:

- [NestJs](https://docs.nestjs.com/) Progressive Node.js server framework
- [TypeOrm](https://typeorm.io) TypeScript ORM (Object Relational Mapper) with `oracledb` support
- [oracledb](https://oracle.github.io/node-oracledb) Oracle Database module

---

## Build Image

⚠️ Build the docker image before proceeding with any other steps

```text
docker build -t mushop/user .
```

## Prepare Environment

The application runtime requires certain environment variables in order to function
properly. Below is a table with information about all variables.

| Variable | Description | Default | Required |
|---|---|---|---|
| `PORT` | Service port | 3000 | N |
| `PORT_USERS` | Alias for `PORT`. Used to disambiguate from other services | 3000 | N |
| `OADB_USER` | ATP Database username | - | Y |
| `OADB_PW` | ATP Database password  | - | Y |
| `OADB_SERVICE` | ATP Database service name assigned by provisioning. (shown as `mymushop_tp` below)  | - | Y |
| `OADB_SCHEMA_USER` | Used to create a schema user with `OADB_USER=admin` | - | N |
| `OADB_SCHEMA_USER_PW` | Used to create schema user pw with `OADB_USER=admin` | - | N |

> **ℹ️ TIP:** Add a `.env` file with the desired values for ease of development

⚠️ An Oracle Database **Wallet** is also required, which contains ATP
connection information. The `Wallet_*.zip` contents must be extracted and bound
to the container volume `/usr/lib/oracle/19.3/client64/lib/network/admin/`

## Create Database Schema

Before running the application, **it is necessary** to prepare the database schema.
This requires an instance of Autonomous Transaction Processing with `admin` credentials.

1. Extract ATP `Wallet_*.zip` contents into the project directory as `Wallet_Creds` or other preferred name.
1. Prepare the application **USER** schema running as `admin`:

    ```text
    docker run --rm \
      -v $PWD/Wallet_Creds:/usr/lib/oracle/19.3/client64/lib/network/admin/ \
      -e OADB_USER=admin \
      -e OADB_PW=${OADB_ADMIN_PW} \
      -e OADB_SERVICE=mymushop_tp \
      -e OADB_SCHEMA_USER=${OADB_USER} \
      -e OADB_SCHEMA_USER_PW=${OADB_PW} \
      npm run schema:user
    ```

    > ℹ️ Creates a new DB user identified as `$OADB_SCHEMA_USER`/`$OADB_SCHEMA_USER_PW`, which are used as `$OADB_USER`/`$OADB_PW` respectively in the runtime.

1. **OPTIONAL:** Synchronize the **USER.TABLE** schema defined by [TypeOrm](https://typeorm.io) entity models:

    ```text
    docker run --rm \
      -v $PWD/Wallet_Creds:/usr/lib/oracle/19.3/client64/lib/network/admin/ \
      -e OADB_USER=${OADB_USER} \
      -e OADB_PW=${OADB_PW} \
      -e OADB_SERVICE=mymushop_tp \
      npm run schema:sync
    ```

    > ⚠️ **NOTE:** This step is required in production, and uses the credentials
      created in the previous step. An alternative would be to execute various
      `CREATE TABLE...` statements directly on the database. Instead
      **[TypeOrm](https://typeorm.io)** does this hard work for us. 

## Develop

Development mode includes dependencies for TypeScript, and developer facilities.

1. Create the development image using `--build-arg` as follows:

    ```text
    docker build --build-arg nodeEnv=development -t mushop/user .
    ```

    > **OR** with `docker-compose`

    ```text
    docker-compose build --build-arg nodeEnv=development
    ```

1. Run the docker container with Wallet and database user credentials.

    ```text
    docker run --rm -it \
      -v $PWD/Wallet_Creds:/usr/lib/oracle/19.3/client64/lib/network/admin/ \
      -e OADB_USER=${OADB_USER} \
      -e OADB_PW=${OADB_PW} \
      -e OADB_SERVICE=${OADB_SERVICE} \
      -p 3000:3000 \
      mushop/user
      npm run start:dev
    ```

    > **OR** with `docker-compose` (assuming environment variables set as above)

    ```text
    docker-compose up
    ```

1. **OPTIONAL:** Replace command with `npm run start:sync` to synchronize ORM schema when necessary.

## Endpoints

### REST

The following table describes the high-level REST endpoints provided
by this service.

| Endpoint | Description | Verb |
|---|---|---|
| `/customers/register` | User registration | `POST` |
| `/customers/login` | User AuthN | `POST` |
| `/customers[/:id]` | CRUD endpoints for **customer** | `GET`, `POST`, `PATCH`, `PUT`, `DELETE` |
| `/customers/:id/cards`, | CRUD endpoints for customer **cards** | `GET`, `POST`
| `/customers/:id/addresses`, | CRUD endpoints for customer **addresses** | `GET`, `POST` |
| `/cards[/:id]`, | CRUD endpoints for **cards** | `GET`, `POST`, `PATCH`, `PUT`, `DELETE` |
| `/addresses[/:id]`, | CRUD endpoints for **addresses** | `GET`, `POST`, `PATCH`, `PUT`, `DELETE` |

### Other Endpoints

| Endpoint | Description | Verb |
|---|---|---|
| `/health` | Readiness healthcheck | `GET` |
| `/metrics` | Prometheus metrics endpoint | `GET` |
