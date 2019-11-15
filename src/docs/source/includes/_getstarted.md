# Getting Started

## Development

> Deploy "mock mode" with `helm`

```shell
helm install deploy/helm-chart/mushop \
  --name mushop \
  --set global.mock.service="all"
```

To get started with the simplest installation, MuShop supports a _mock mode_
deployment option where cloud backing services are mocked, yet the application
remains fully functional.

<aside class="notice">
  It may take a few moments to download all the application images.
  It is also normal for some pods to show errors in mock mode.
</aside>

> Wait for services to be _Ready_

```shell
kubectl get pod --watch
```

## Cloud

1. Create Resource Manager Stack
1. Apply Terraform configuration
1. Setup OKE cluster
1. Configure helm chart
1. Install