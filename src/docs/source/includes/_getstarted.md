# Getting Started

This project supports deployment modes for the purposes of demonstrating
different functionality on Oracle Cloud Infrastructure. While the source code
is identical across these options, certain services are omitted in the `basic`
deployment.

| [Basic: `deploy/basic`](#basic-cloud-installation) | [Cloud Native: `deploy/complete`](#cloud-native-installation) |
|--|--|
| Simplified runtime utilizing **only** [Always Free](https://www.oracle.com/cloud/free/) resources deployed with [Resource Manager](https://www.oracle.com/cloud/systems-management/resource-manager/) | Full-featured [Kubernetes](https://kubernetes.io/) microservices deployment showcasing Oracle [Cloud Native](https://www.oracle.com/cloud/cloud-native/) technologies and backing services |

```text
mushop
└── deploy
    ├── basic
    └── complete
```

> Options for different MuShop deployment modes

## Basic Cloud Installation

This deployment is designed to run using **only** Always Free resources.
It uses MuShop source code and the Oracle Cloud Infrastructure
[Terraform Provider](https://www.terraform.io/docs/providers/oci/index.html) to
produce a [Resource Manager](https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) stack,
that _provisions_ all required resources and _configures_ the application on
those resources.

```shell
cd deploy/basic
```

> Source directory for basic deployment option

These steps outline the **Basic** deployment using Resource Manager:

1. Download the latest [`mushop-basic-stack-v1.x.x.zip`](https://github.com/oracle-quickstart/oci-cloudnative/releases) file.

1. [Login](https://console.us-ashburn-1.oraclecloud.com/resourcemanager/stacks/create) to the console to import the stack.

    > Home > Solutions & Platform > Resource Manager > Stacks > Create Stack

1. Upload the `mushop-basic-stack-v1.x.x.zip` file that was downloaded earlier, and provide a name and description for the stack.

1. Specify configuration options:

    1. **Database Name** - You can choose to provide a database name (optional)
    1. **Node Count** - Select if you want to deploy one or two application instances.
    1. **Availability Domain**  - Select any availability domain to create the resources. If you run in to service limits, you could try another availability domain.

1. Review the information and click `Create` button.

    > The upload can take a few seconds, after which you will be taken to the newly created stack

1. On Stack details page, select `Terraform Actions > Apply`

<aside class="notice">
  The application is deployed to the compute instances <strong>asynchronously</strong>,
  and it may take a few minutes for the public URL to serve the application.
</aside>

## Cloud Native Installation

This deployment option utilizes [`helm`](https://github.com/helm/helm) for
configuration and installation onto a [Kubernetes](https://kubernetes.io/)
cluster. It is _recommended_ to use an
[Oracle Container Engine for Kubernetes](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm)
cluster, however other **standard** Kubernetes clusters will also work.

```text
cd deploy/complete/helm-chart
```

> Path for Cloud Native deployment configurations using `helm`

Deploying the complete MuShop application with backing services from Oracle Cloud
Infrastructure involves the use of the following helm charts:

1. [`setup`](#setup): Installs umbrella chart dependencies on the cluster _(optional)_
1. [`provision`](#provision): Provisions OCI resources integrated with Service Broker _(optional)_
1. [`mushop`](#installation): Deploys the MuShop application runtime

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

    ```shell
    helm install setup \
      --name mushop-setup \
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

    ```shell
    helm install mushop \
      --name mushop \
      --set global.mock.service="all"
    ```

1. Wait for services to be _Ready_:

    ```shell
    kubectl get pod --watch
    ```

1. Open a browser with the `EXTERNAL-IP` created during setup, **OR** `port-forward`
directly to the `edge` service resource:

    ```shell
    kubectl port-forward \
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
