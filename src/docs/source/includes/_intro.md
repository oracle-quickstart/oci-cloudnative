# Introduction

> MuShop microservices
>
| Service | Language  | Cloud Services | Description |
| --- | --- | --- | --- |
| `api` | Node.js   | | Storefront API |
| `carts` | Java | Autonomous DB (ATP) | Shopping cart |
| `catalogue` | Go | Autonomous DB (ATP) | Product catalogue |
| `orders` | Java | Autonomous DB (ATP)   | Customer orders |
| `payments` | Go | | Payment processing |
| `router` | traefik  |  | Request routing |
| `shipping` | Java | Streaming | Shipping producer |
| `stream` | Java | Streaming | Shipping fulfillment |
| `storefront` | JavaScript  |  | Store UI |
| `user` | TypeScript | Autonomous DB (ATP)  | Customer accounts |

MuShop is a microservices demo application **purpose-built** to showcase
interoperable _Cloud Native_ services on
[Oracle Cloud Infrastructure](https://www.oracle.com/cloud/cloud-native/).

The premise of MuShop is an e-commerce website offering a variety of cat
products. It represents a polyglot microservice application, with **actual use case**
scenarios for many Oracle Cloud Infrastructure services.

![mushop](mushop.home.png "MuShop UI")

<!-- <blockquote class="o-align-content">
  <p>
    hey
  </p>
</blockquote> -->