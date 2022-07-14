# MuShop Services - Source

Source code for each service of the MuShop solution

## Services

| Service                                                  | Language         | Cloud Services      | Arch Support | Description                                                                                                                   | Build Status  |
| -------------------------------------------------------- | ---------------- | ------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [api](./api)                                         | Node.js          |                     | amd64  arm64 | Orchestrating services for consumption by Storefront |   |
| [assets](./assets)                                   | Node.js          |                     | amd64  arm64 | Populates initial images to be consumed by Catalogue service |   |
| [carts](./carts)                                     | Java             | Autonomous DB (ATP) |     amd64    | Provides shopping carts for users |   |
| [catalogue](./catalogue)                             | Go               | Autonomous DB (ATP) | amd64  arm64 | Provides catalogue/product information stored on Oracle Autonomous Database. Uses GOdror with GoKit and OCI Service Broker    |  |
| [dbtools](./dbtools)                                 | Oracle DB Client | Autonomous DB (ATP) | amd64  arm64 |  Simple image with Oracle Instant Client, SQLce and dev tools |   |
| [edge-router](./edge-router)                         | traefik          | Development only    |     amd64    | Optional Edge routing container for MuShop backend/frontend services. Used for running development environments                   |   |
| [events](./events)                                   | Go               | OCI Streaming       |     amd64    | Capture events on the Storefront and showcase OCI Streams                   |   |
| [fulfillment](./fulfillment)                         | Micronaut        |                     |     amd64    | fulfillment service showcasing Micronaut and Java                   |   |
| [newsletter-subscription](./newsletter-subscription) | Javascript       |                     |     amd64    | Javascript Function showcasing email service                   |   |
| [load](./load)                                       | Locust           |                     | amd64  arm64 | Capture events on the Storefront                   |   |
| [orders](./orders)                                   | Java             | Autonomous DB (ATP) |     amd64    | Orders service using Springboot |   |
| [payment](./payment)                                 | Go               |                     | amd64  arm64 | Payment processing service |   |
| [storefront](./storefront)                           | Node.js          |                     | amd64  arm64 | Responsive eCommerce storefront single page application built on microservices |   |
| [user](./user)                                       | TypeScript       | Autonomous DB (ATP) |     amd64    | Customer account service + AuthN |   |

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

## Running APIs on Postman

Testing MuShop Services APIs with Postman.

| Service                                                  | Postman                                                                        |
| -------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [catalogue](./catalogue)                             | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_catalogue] |
| [user](./user)                                       | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_user]      |
| [payment](./payment)                                 | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_payment]   |
| [api](./api)                                         | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_api]       |

[postman_button_catalogue]: https://god.gw.postman.com/run-collection/29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1?action=collection%2Ffork&collection-url=entityId%3D29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_user]: https://god.gw.postman.com/run-collection/29850-d02fc1f5-cec7-4f00-9f25-092e64e7f726?action=collection%2Ffork&collection-url=entityId%3D29850-d02fc1f5-cec7-4f00-9f25-092e64e7f726%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_payment]: https://god.gw.postman.com/run-collection/29850-cd57303a-f3df-4a22-8e18-09cd2218d94a?action=collection%2Ffork&collection-url=entityId%3D29850-cd57303a-f3df-4a22-8e18-09cd2218d94a%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_api]: ()
