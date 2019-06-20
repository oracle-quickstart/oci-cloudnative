# Edge Router

Edge routing container for MuShop backend/frontend services.

> **NOTE** This service is used for running **development environments** with Docker
_outside_ of Oracle Cloud Infrastructure

## Build

```shell
docker build -t mushop/edge-router .
```

## Push to Oracle Container Registry

1. Define OCIR environment variable `export OCIR=phx.ocir.io/{tenancy}`
1. Login with docker `docker login {tenancy}/{username} phx.ocir.io`
1. `./scripts/push.sh [tag]`
