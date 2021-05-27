# MuShop Services - Source

Source code for each service of the MuShop solution

## Services

| Service                                                  | Language         | Cloud Services      | Arch Support | Description                                                                                                                   | Build Status  |
| -------------------------------------------------------- | ---------------- | ------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [api](./src/api)                                         | Node.js          |                     | amd64  arm64 | Orchestrating services for consumption by Storefront |   |
| [assets](./src/assets)                                   | Node.js          |                     | amd64  arm64 | Populates initial images to be consumed by Catalogue service |   |
| [carts](./src/carts)                                     | Java             | Autonomous DB (ATP) |     amd64    | Provides shopping carts for users |   |
| [catalogue](./src/catalogue)                             | Go               | Autonomous DB (ATP) | amd64  arm64 | Provides catalogue/product information stored on Oracle Autonomous Database. Uses GOdror with GoKit and OCI Service Broker    |  |
| [dbtools](./src/dbtools)                                 | Oracle DB Client | Autonomous DB (ATP) |     amd64    | Simple image with Oracle Instant Client, SQLce and dev tools |   |
| [edge-router](./src/edge-router)                         | traefik          | Development only    |     amd64    | Optional Edge routing container for MuShop backend/frontend services. Used for running development environments                   |   |
| [events](./src/events)                                   | Go               | OCI Streaming       |     amd64    | Capture events on the Storefront and showcase OCI Streams                   |   |
| [fulfillment](./src/fulfillment)                         | Micronaut        |                     |     amd64    | fulfillment service showcasing Micronaut and Java                   |   |
| [newsletter-subscription](./src/newsletter-subscription) | Javascript       |                     |     amd64    | Javascript Function showcasing email service                   |   |
| [load](./src/load)                                       | Locust           |                     | amd64  arm64 | Capture events on the Storefront                   |   |
| [orders](./src/orders)                                   | Java             | Autonomous DB (ATP) |     amd64    | Orders service using Springboot |   |
| [payment](./src/payment)                                 | Go               |                     | amd64  arm64 | Payment processing service |   |
| [storefront](./src/storefront)                           | Node.js          |                     | amd64  arm64 | Responsive eCommerce storefront single page application built on microservices |   |
| [user](./src/user)                                       | TypeScript       | Autonomous DB (ATP) |     amd64    | Customer account service + AuthN |   |

## Building

Each service needs a Dockerfile to build an image for the correspondent service. Should be able to complete the build without manual interaction.

The Dockerfile should be able to successfully build the image on the PR before commit to main.

Together with the Dockerfile, the service folder should contain the VERSION one-line file, with the semver (major.minor.patch) format.

Optionally, if the service supports, add the PLATFORMS one-line file with the architecture platform to be included on the Container Image Manifest. e.g.: (linux/amd64,linux/arm64). If not file is included, the build defaults to linux/amd64.

Service Example:

```profile
src
│   README.md (this file)
│
└───payment
│   │   Dockerfile
│   │   VERSION
│   │   PLATFORMS
│   │   service.go
│   │
│   └───cmd
│       │   main.go
│       │   ...
│   
└───load
    │   Dockerfile
    │   VERSION
    │   ...
```
