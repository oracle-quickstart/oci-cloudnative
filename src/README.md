# MuShop Services - Source

Source code for each service of the MuShop solution

## Services

| Service                                                  | Language         | Cloud Services      | Description                                                                                                                   | Build Status  |
| -------------------------------------------------------- | ---------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [api](./src/api)                                         | Node.js          |                     | Orchestrating services for consumption by Storefront |   |
| [assets](./src/assets)                                   | Node.js          |                     | Populates initial images to be consumed by Catalogue service |   |
| [carts](./src/carts)                                     | Java             | Autonomous DB (ATP) | Provides shopping carts for users |   |
| [catalogue](./src/catalogue)                             | Go               | Autonomous DB (ATP) | Provides catalogue/product information stored on Oracle Autonomous Database. Uses GOdror with GoKit and OCI Service Broker    |  |
| [dbtools](./src/dbtools)                                 | Oracle DB Client | Autonomous DB (ATP) | Simple image with Oracle Instant Client, SQLce and dev tools |   |
| [edge-router](./src/edge-router)                         | traefik          | Development only    | Optional Edge routing container for MuShop backend/frontend services. Used for running development environments                   |   |
| [events](./src/events)                                   | Go               | OCI Streaming       | Capture events on the Storefront and showcase OCI Streams                   |   |
| [fulfillment](./src/fulfillment)                         | Micronaut        |                     | fulfillment service showcasing Micronaut and Java                   |   |
| [newsletter-subscription](./src/newsletter-subscription) | Javascript       |                     | Javascript Function showcasing email service                   |   |
| [load](./src/load)                                       | Locust           |                     | Capture events on the Storefront                   |   |
| [orders](./src/orders)                                   | Java             | Autonomous DB (ATP) | Orders service using Springboot |   |
| [payment](./src/payment)                                 | Go               |                     | Payment processing service |   |
| [storefront](./src/storefront)                           | Node.js          |                     | Responsive eCommerce storefront single page application built on microservices |   |
| [user](./src/user)                                       | TypeScript       | Autonomous DB (ATP) | Customer account service + AuthN |   |

## Building

Each service needs a Dockerfile to build an image for the correspondent service. Should be able to complete the build without manual interaction.

The Dockerfile should be able to successfully build the image on the PR before commit to main.

Together with the Dockerfile, the service folder should contain the VERSION one-line file, with the semver (major.minor.patch) format.

Optionally, if the service supports, add the PLATFORMS one-line file with the architecture platform to be included on the Container Image Manifest. e.g.: (linux/amd64,linux/arm64). If not file is included, the build defaults to linux/amd64.
