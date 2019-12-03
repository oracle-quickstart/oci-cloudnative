# MuShop Docs

This documentation is based on the
[slate](https://github.com/slatedocs/slate) documentation framework, and adapted for use in docker.

## Development

```shell
docker-compose up
```

## Build

1. Build the docker image `mushop/docs`

    ```shell
    docker build -t mushop/docs .
    ```

1. Transfer build outputs to `build` working directory

    ```shell
    docker run --rm -v $(pwd):/transfer --entrypoint mv \
      mushop/docs:latest \
      build /transfer
    ```

## Deploy

After build, deploy to origin `gh-pages` branch as follows:

```shell
./deploy.sh --push-only
```
