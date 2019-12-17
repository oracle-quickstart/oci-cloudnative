# Getting Started

This project supports deployment modes for the purposes of demonstrating
different functionality on Oracle Cloud Infrastructure. While the source code
is identical across these options, certain services are omitted in the `basic`
deployment.

| [Basic: `deploy/basic`](#basic-deployment) | [Cloud Native: `deploy/complete`](#kubernetes-deployment) |
|--|--|
| Simplified runtime utilizing **only** [Always Free](https://www.oracle.com/cloud/free/) resources deployed with [Resource Manager](https://www.oracle.com/cloud/systems-management/resource-manager/) | Full-featured [Kubernetes](https://kubernetes.io/) microservices deployment showcasing Oracle [Cloud Native](https://www.oracle.com/cloud/cloud-native/) technologies and backing services |

```text
mushop
└── deploy
    ├── basic
    └── complete
```
