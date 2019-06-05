# MuShop

The Microservices Demo using Oracle Cloud Infrastructure (OCI) - Rebranded to MuShop

## Services

| Service                           | Language  | Cloud Services        | Description                                                                                                                       | Build Status  |
| --------------------------------- | --------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [api](./src/api)                  | Node.js   |                       | Orchestrating services for consumption by Storefront                                                                              |   |
| [carts](./src/carts)              | Java      | Autonomous DB (ATP)   | Provides shopping carts for users                                                                                                 |   |
| [catalogue](./src/catalogue)      | Go        | Autonomous DB (ATP)   | Provides catalogue/product information stored on Oracle Autonomous Database. Uses GOracle.v2 with GoKit and OCI Service Broker    | [![wercker status](https://app.wercker.com/status/f59f625d8e8d9c33c00378517e1b26bb/s/ "wercker status")](https://app.wercker.com/project/byKey/f59f625d8e8d9c33c00378517e1b26bb)|
| [orders](./src/orders)            | Java      | Autonomous DB (ATP)   | Orders service using Springboot                                                                                                   |   |
| [payments](./src/payments)        | Go        |                       | TBD                                                                                                                               |   |
| [queue](./src/queue)              | Java      | Oracle Streaming      | Consumes shipping messages from OCI Streams                                                                                       |   |
| [shipping](./src/shipping)        | Java      | Oracle Streaming      | Receives  messages when an item is shipped and forward to Oracle Streams                                                                                   |   |
| [storefront](./src/storefront)    | Node.js   |                       | Responsive eCommerce storefront single page application built on microservices architecture.                                      |   |
| [user](./src/user)                | Go        |                       | TBD                                                                                                                               |   |
| [edge-router](./src/edge-router)  | traefik   | Development only      | Optional Edge routing container for MuShop backend/frontend services. Used for running development environments                   |   |
