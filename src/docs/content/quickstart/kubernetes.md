---
title: "Kubernetes Deployment"
date: 2020-03-06T12:27:43-07:00
draft: false
weight: 20
tags:
  - Kubernetes
  - OKE
  - Setup
  - Mock Mode
---

This deployment option utilizes [`helm`](https://github.com/helm/helm) for
configuration and installation onto a [Kubernetes](https://kubernetes.io/)
cluster. It is _recommended_ to use an
[Oracle Container Engine for Kubernetes](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm)
cluster, however other **standard** Kubernetes clusters will also work.

```shell--linux-macos
cd deploy/complete/helm-chart
```

```shell--win
dir deploy/complete/helm-chart
```

> Path for Cloud Native deployment configurations using `helm`

Deploying the complete MuShop application with backing services from Oracle Cloud
Infrastructure involves the use of the following helm charts:

1. [`setup`](#setup): Installs umbrella chart dependencies on the cluster _(optional)_
1. [`provision`](#provision): Provisions OCI resources integrated with Service Broker _(optional)_
1. [`mushop`](#deploy-mushop): Deploys the MuShop application runtime

To get started, create a namespace for the application and its associative deployments:

```shell
kubectl create ns mushop
```

---

### Setup

{{% content/setup %}}

### Deploy MuShop

To get started with the simplest installation, MuShop supports a _mock mode_
deployment option where cloud backing services are disconnected or **mocked**,
yet the application remains fully functional. This is useful for development,
testing, and cases where cloud connectivity is not available.

From `deploy/complete/helm-chart` directory:

1. Deploy _"mock mode"_ with `helm`:

    ```shell--helm2
    helm install mushop \
      --name mushop \
      --namespace mushop \
      --set global.mock.service="all"
    ```

    ```shell--helm3
    helm upgrade --install mushop mushop \
      --namespace mushop \
      --create-namespace \
      --set global.mock.service="all"
    ```

1. Wait for services to be _Ready_:

    ```shell
    kubectl get pod --watch --namespace mushop
    ```

1. Open a browser with the `EXTERNAL-IP` created during setup, **OR** `port-forward`
directly to the `edge` service resource:

    ```shell
    kubectl port-forward \
      --namespace mushop \
      svc/edge 8000:80
    ```

    > Using `port-forward` connecting [localhost:8000](http://localhost:8000) to the `edge` service

    ```shell
    kubectl get svc mushop-utils-ingress-nginx-controller \
      --namespace mushop-utilities
    ```

    > Locating `EXTERNAL-IP` for Ingress Controller. **NOTE** this will be
    [localhost](https://localhost) on local clusters.

<aside class="warning">
  It may take a few moments to download all the application images.
  It is also normal for some pods to show errors in mock mode.
</aside>
