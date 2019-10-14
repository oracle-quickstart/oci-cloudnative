# MuShop Helm Chart

The helm charts here can be used to install all components of MuShop to the Kubernetes cluster.
For practical purposes, multiple charts are used to separate installation into the following steps:

1. `[setup](#setup)` Installs _optional_ chart dependencies on the cluster
1. `[provision](#provision)` Provisions OCI resources integrated with Service Broker _(optional)_
1. `[mushop](#mushop)` Deploys the MuShop application runtime

## Setup

The `setup` chart includes several recommended installations on the cluster. These
installations represent common 3rd party services, which integrate with
Oracle Cloud Infrastructure or enable certain features within the application.

1. Update chart dependencies:

    ```text
    helm dependency update setup
    ```

    > This is necessary because chart binaries are not included inside the source code

1. Install `setup` chart:

    ```text
    helm install setup --name mushop-setup --namespace --mushop-setup
    ```

    > **NOTE:** It is possible that certain services may conflict with pre-existing installs. If so, try editing using `--set <chart>.enabled=false` any conflicting charts.

> Example setting with alternate LoadBalancer port:

```text
helm install setup --set nginx-ingress.controller.service.ports.http=8000
```

The installed dependencies are listed below. Note that any can be disabled as needed.

| Chart | Purpose | Option |
|---|---|---|
| [Prometheus](https://github.com/helm/charts/blob/master/stable/prometheus/README.md) | Service metrics aggregation | `prometheus.enabled` |
| [Grafana](https://github.com/helm/charts/blob/master/stable/grafana/README.md) | Infra/Service visualization dashboards | `grafana.enabled` |
| [Metrics Server](https://github.com/helm/charts/blob/master/stable/metrics-server/README.md) | Support for Horizontal Pod Autoscaling | `metrics-server.enabled` |
| [Service Catalog](https://github.com/kubernetes-sigs/service-catalog/blob/master/charts/catalog/README.md) | Interface for Oracle Service Broker | `catalog.enabled` |
| [Nginx Ingress](https://github.com/helm/charts/blob/master/stable/nginx-ingress/README.md) | Load Balancer ingress control | `nginx-ingress.enabled` |

## Provision

- OSB oci credentials secret file
- Service provisioning: ATP, Streaming?
- Secret Binding (Available to runtime)
- TODO...

## Prerequisites

- Secrets as defined in the `/secrets` folders for each of the following:
    1. . [./mushop/secrets](./secrets/README.md)
    1. Carts [./mushop/charts/carts/secrets](./mushop/charts/carts/secrets/README.md)
    1. Catalogue [./mushop/charts/catalogue/secrets](./mushop/charts/catalogue/secrets/README.md)
    1. Orders [./mushop/charts/orders/secrets](./mushop/charts/orders/secrets/README.md)
    1. Users [./mushop/charts/user/secrets](./mushop/charts/user/secrets/README.md)

> Example folders with secrets in place. This shows a single DB Wallet used

```text
mushop/
├── charts
│   ├── carts
│   │   └── secrets
│   │       └── Wallet_mymushopdb
│   ├── catalogue
│   │   └── secrets
│   │       └── Wallet_mymushopdb
│   ├── orders
│   │   └── secrets
│   │       └── Wallet_mymushopdb
│   └── user
│       └── secrets
│   │       └── Wallet_mymushopdb
└── secrets
    └── oci_streams_api_key.pem
```

## Installation

### Mock Installation

For an installation without using the OCI services, use the following:

```bash
helm install mushop --name mymushop \
    --set global.mock.service=all
```

### Dev installation

The default chart installation creates an Ingress resource for development (i.e. simple Ingress, without the DNS and need for Prod/Staging secrets).

Before installing the chart, ensure all [prerequistes](#prerequisites) are met.

To install the chart, make a copy of the `values.yaml` file, fill in the missing values (e.g. secrets) and then run:

```bash
helm install mushop --name mymushop -f myvalues.yaml
```

If you want to troubleshoot the chart, add the `--dry-run` and `--debug` flags and re-run the command again. For example:

```bash
helm install mushop --dry-run --debug --name mymushop -f myvalues.yaml
```

### Installing HPA for components

Optionally, you can enable HPA for components by setting the `hpa.enabled` property to `true`. For example: `api.hpa.enabled=true`, and then pass it to the install command:

```bash
helm install --dry-run --debug mushop --name mymushop -f myvalues.yaml \
    --set api.hpa.enabled=true
```

## Prod/Test Installation

### Installing cert-manager

You only need to run this if you are installing Mushop on a new cluster *and* you want to use SSL. You need to install the CRDs first, before running Helm for cert-manager:

```
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
```

Create the `cert-manager` namespace and label it to disable validation:

```
kubectl create ns cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true"
```

Add the JetStack Helm repo:

```
helm repo add jetstack https://charts.jetstack.io
```

Install the `cert-manager` Helm chart:

```
helm install --name cert-manager --namespace cert-manager jetstack/cert-manager
```

### Installing Mushop

For prod/test installation, you can use the `values-prod.yaml` or `values-test.yaml` and call Helm install and pass in the values file:

```bash
helm install --dry-run --debug mushop -f /mushop/values-prod.yaml --name mymushop
```

## Creating all/individual YAML files

If you don't want to deploy the charts, you can also render the template and get all YAML files by running the `template` command,  providing an output directory and the values file to use.

```bash
helm template mushop --output-dir <SOME_DIR> -f <VALUES_FILE> --name mymushop
```
