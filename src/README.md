# source
Source code of the MuShop Lite

# Build

- Clone MuShop
- From the root of the repo exeucte the command:
 `docker build -t mushop-lite-mono -f deploy/monolith-lite/Dockerfile .`

# [Monolith] Copy generated App Zip Package for VM

- `docker run -v $PWD/deploy/terraform/lite/scripts:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono.tar.gz /transfer/mushop-lite-mono.tar.gz`

# [Monolith] Copy generated Generate Stack Zip Package for the ORM

- `docker run -v $PWD:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono-stack.zip /transfer/mushop-lite-mono-stack.zip`