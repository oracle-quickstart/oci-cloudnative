## Kubernetes Deployment

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

MuShop provides an umbrella helm chart called `setup`, which includes several
_recommended_ installations on the cluster. These represent common 3rd party
services, which integrate with Oracle Cloud Infrastructure or enable certain
application features.

| Chart | Purpose | Option |
|---|---|---|
| [Prometheus](https://github.com/helm/charts/blob/master/stable/prometheus/README.md) | Service metrics aggregation | `prometheus.enabled` |
| [Grafana](https://github.com/helm/charts/blob/master/stable/grafana/README.md) | Infrastructure/service visualization dashboards | `grafana.enabled` |
| [Metrics Server](https://github.com/helm/charts/blob/master/stable/metrics-server/README.md) | Support for Horizontal Pod Autoscaling | `metrics-server.enabled` |
| [Nginx Ingress](https://github.com/helm/charts/blob/master/stable/nginx-ingress/README.md) | Ingress controller and public Load Balancer | `nginx-ingress.enabled` |
| [Service Catalog](https://github.com/kubernetes-sigs/service-catalog/blob/master/charts/catalog/README.md) | Service Catalog chart utilized by Oracle Service Broker | `catalog.enabled` |

> Dependencies installed with `setup` chart. **NOTE** as these are very common installations, each may be disabled as needed to resolve conflicts.

From `deploy/complete/helm-chart` directory:

1. Add required helm repositories:

    ```shell
    helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
    helm repo add stable https://kubernetes-charts.storage.googleapis.com
    ```

1. Install chart dependencies:

    ```shell
    helm dependency update setup
    ```

1. Install `setup` chart:

    ```shell--helm2
    helm install setup \
      --name mushop-setup \
      --namespace mushop-setup
    ```

    ```shell--helm3
    kubectl create ns mushop-setup
    ```

    ```shell--helm3
    helm install mushop-setup setup \
      --namespace mushop-setup
    ```

1. **NOTE** the public `EXTERNAL-IP` assigned to the ingress controller load balancer:

    ```shell
    kubectl get svc mushop-setup-nginx-ingress-controller \
      --namespace mushop-setup
    ```

### Deploy MuShop

To get started with the simplest installation, MuShop supports a _mock mode_
deployment option where cloud backing services are disconnected or **mocked**,
yet the application remains fully functional. This is useful for development,
testing, and cases where cloud connectivity is not available.

From `deploy/complete/helm-chart` directory:

1. Deploy "mock mode" with `helm`:

    ```shell--helm2
    helm install mushop \
      --name mushop \
      --namespace mushop \
      --set global.mock.service="all"
    ```

    ```shell--helm3
    helm install mushop ./mushop \
      --namespace mushop \
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
    kubectl get svc mushop-setup-nginx-ingress-controller \
      --namespace mushop-setup
    ```

    > Locating `EXTERNAL-IP` for Ingress Controller. **NOTE** this will be
    [localhost](https://localhost) on local clusters.

<aside class="warning">
  It may take a few moments to download all the application images.
  It is also normal for some pods to show errors in mock mode.
</aside>
