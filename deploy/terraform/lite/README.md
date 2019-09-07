# Mushop - **Mono***lite* Edition

Terraform based Resource manager stack that deploys Mushop on a standalone VM.

# Build

- Clone MuShop
- From the root of the repo exeucte the command:
 `docker build -t mushop-lite-mono -f deploy/monolith-lite/Dockerfile .`


# Generate **Mono***lite* package for VM

- `docker run -v $PWD/deploy/terraform/lite/scripts:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono.tar.gz /transfer/mushop-lite-mono.tar.gz`

## Monolith VM details

- Base EL7
- oracle-instantclient19.3-basic, oracle-instantclient19.3-sqlplus
- node 10.x, httpd, jq


## **Mono***lite*

This terraform configuration is designed to be imported in to the OCI as a Resource Manager *stack*. Once imported,
the user will can use the Resource Manager to deploy the application sample to a single VM. This is mode uses a transient cache for the `carts,orders,users` services and hooks up catalogue to an ATP instance that is provisioned by the terraform configuration.

  