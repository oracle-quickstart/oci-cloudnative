# Mushop - **Mono***lite* Edition

Terraform based Resource manager stack that deploys Mushop on a standalone VM.



## **Mono***lite*

This terraform configuration is designed to be imported in to the OCI as a Resource Manager *stack*. Once imported,
the user will can use the Resource Manager to deploy the application sample to a single VM. This is mode uses a transient cache for the `carts,orders,users` services and hooks up catalogue to an ATP instance that is provisioned by the terraform configuration.

This stack when executed will do the following

- Create the infrastructure networking components
- Push application artifacts like the binaries and configuration files to object storage
- Create an ATP instance
  - The ATP wallets are pushed to an object storage bucket.
- Create the compute instance
  - the application artifacts like the app binaries and ATP wallets location in object storage are provided to the instance through its metadata.
  - dependent packages like the oracle instant client and node js are installed.
  - pulldown the wallets and other artifacts from the object storage
  - initialize the database. create the schema and seed the data.
  - bootstrap the application

### Infrastucture

This ORM stack creates the following resources
- Compute
  - VM.Standard.E2.1 -- !! Will be updated to use a VM.Standard.E2.1.Micro !!
- Database
  - ATP instance
- Networking
  - VCN
  - Regional Subnet
  - Internet Gateway, Route Tables and Security lists (ingress on :80, :22)
  - If using the HA version, a load balancer is also included.
- Storage
  - An object storage bucket
  - Objects including the application binaries are pushed to this bucket.
  - PAR objects to make access easier. PAR for the DB wallet will expire in 30m after the DB being created.

### Monolith VM details

- Base EL7
- oracle-instantclient19.3-basic, oracle-instantclient19.3-sqlplus
- node 10.x, httpd, jq

# Build

- Clone MuShop
- From the root of the repo exeucte the command:
 `docker build -t mushop-lite-mono -f deploy/monolith-lite/Dockerfile .`


# Generate **Mono***lite* package for VM

- `docker run -v $PWD/deploy/terraform/lite/scripts:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono.tar.gz /transfer/mushop-lite-mono.tar.gz`