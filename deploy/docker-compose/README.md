# MuShop Docker

The complete **MuShop** application can be run using `docker-compose`

## Prerequisites

The docker environment requires several environment variables in order to function
properly. These can be added as an `.env` file in the directory from which you're
executing commands.

| Variable | Description  |
|---|---|
| `OCI_TENANT_ID` | The _tenancy_ OCID |
| `OCI_COMPARTMENT_ID` | The _compartment_ OCID |
| `OCI_USER_ID` | The _user_ OCID with access to use resources in the compartment |
| `OCI_REGION` | Region identifier |
| `OCI_FINGERPRINT` | The fingerprint for `OCI_API_KEY` (See note) |
| `OCI_API_KEY` | A `pem` formatted **string** OCI API key associated with the user |

> Example `.env` file

```text
OCI_TENANT_ID=ocid1.tenancy.oc1..aaaaaaaaXXXXXXXXXX
OCI_COMPARTMENT_ID=ocid1.compartment.oc1..aaaaaaaaXXXXXXXXXX
OCI_USER_ID=ocid1.user.oc1..aaaaaaaaXXXXXXXXXX
OCI_REGION=us-phoenix-1
OCI_FINGERPRINT=fc:ef:f0:6f:e2:df:df:6e:10:54:70:17:06:d2:94:3c
OCI_API_KEY="-----BEGIN RSA PRIVATE KEY-----\nMIIE...udA==\n-----END RSA PRIVATE KEY-----"
```

**NOTE:** `OCI_FINGERPRINT` can be obtained with a command such as the following:

```shell
openssl rsa -pubout -outform DER -in ~/path/to/key.pem | openssl md5 -c
```

## Quick Start

```shell
# From this directory
docker-compose up -d

# From the mushop root
docker-compose -f deploy/docker-compose/docker-compose.yml up -d
```

Open [http://localhost](http://localhost) in your browser.

## Shutdown

```shell
# From this directory
docker-compose down
# From the mushop root
docker-compose -f deploy/docker-compose/docker-compose.yml down
```
