# Events

A microservices-demo service that provides event streaming services.

## API Spec

See the API Spec [here](./api-spec/events.json)

## Build

### Native Go

```shell
go build -o ./app cmd/main.go
```

The result is a binary named `app`, in the current directory.

#### Docker

`docker build -t mushop/events .`

`docker-compose build`

## Run

## Environment

The events service requires several environment configurations in order to produce messages on an Oracle Cloud Infrastructure Stream.

| Variable | Description | Default | Required |
|---|---|---|---|
| `TENANCY` | Tenancy OCID string |  | Y |
| `USER_ID` | IAM User OCID string |  | Y |
| `PRIVATE_KEY` | API Private Key (pem) |  | Y |
| `FINGERPRINT` | API Key Fingerprint  |  | Y |
| `PASSPHRASE` | API Key passphrase  |  | N |
| `REGION` | Oracle Cloud Infrastructure region (ex: `us-ashburn-1`)  |  | Y |
| `STREAM_ID` | Stream OCID string |  | Y |
| `MESSAGES_ENDPOINT` | Stream messages endpoint string (resolved from region if empty) |  | N |

### Using Go native

```shell
go run cmd/main.go
ts=2020-02-18T21:20:46.333405Z caller=main.go:88 transport=HTTP port=8080
```

### Using Docker Compose

```shell
docker-compose up
```

Access the service via http://localhost:8080

## Check

Test the health of the service by doing a GET request to the `/health` endpoint:

```shell
curl http://localhost:8080/health
# {"health":[{"service":"events","status":"OK","time":"2020-02-16 12:22:04.716316395 +0000 UTC"}]}
```

## Use

You can produce events by POSTing to the `/events` endpoint:

```shell
curl -H "Content-Type: application/json" -X POST -d'{"source":"test","track":"abc123","events":[{"type":"any"}]}' http://localhost:8080/events
```
