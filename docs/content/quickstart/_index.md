---
title: "Getting Started"
date: 2020-03-05T15:34:14-07:00
weight: 1
draft: false
tags:
  - Quickstart
  - Source code
---

This project supports deployment modes for the purposes of demonstrating
different functionality on Oracle Cloud Infrastructure. While the source code
is identical across these options, certain services are omitted in the `basic`
deployment.

| [Basic: `deploy/basic`](basic) | [Cloud Native: `deploy/complete`](kubernetes) |
|--|--|
| Simplified runtime utilizing **only** [Always Free](https://www.oracle.com/cloud/free/) resources deployed with [Resource Manager](https://www.oracle.com/cloud/systems-management/resource-manager/) | Full-featured [Kubernetes](https://kubernetes.io/) microservices deployment showcasing Oracle [Cloud Native](https://www.oracle.com/cloud/cloud-native/) technologies and backing services |

```text
mushop
└── deploy
    ├── basic
    └── complete
```

## Clone Repository

Each topic in this material references the source code, which should be
cloned to a personal workspace.

```shell--macos-linux
git clone https://github.com/oracle-quickstart/oci-cloudnative.git mushop
cd mushop
```

```shell--win
git clone https://github.com/oracle-quickstart/oci-cloudnative.git
dir mushop
```

## Structure

The source code will look something like the following:

```text
#> mushop
├── deploy
│   ├── basic
│   └── complete
│       ├── docker-compose
│       ├── helm-chart
│       └── kubernetes
└── src
    ├── api
    ├── assets
    ├── carts
    ├── catalogue
    ├── edge-router
    ├── events
    ├── fulfillment
    ├── dbtools
    ├── load
    ├── orders
    ├── payment
    ├── storefront
    └── user
```

- `deploy`: Collection of application deployment resources.
- `src`: Individual service source code, Dockerfiles, etc.
