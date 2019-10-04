# MuShop Helm Chart

The `mushop` Helm chart can be used to install all components of the MuShop to the Kubernetes cluster.

## Prerequisites

- Kubernetes cluster
- Helm
- Secrets as defined in the `/secrets` folders for each of the following:
    1. Root [./mushop/secrets](./secrets/README.md)
    1. Carts [./mushop/charts/carts/secrets](./mushop/charts/carts/secrets/README.md)
    1. Orders [./mushop/charts/orders/secrets](./mushop/charts/orders/secrets/README.md)
    1. Users [./mushop/charts/user/secrets](./mushop/charts/user/secrets/README.md)

## Installation

Before installing the chart, it is necessary to load the chart dependencies

```text
helm dependency update mushop
```

> This is necessary because chart binaries are not included inside the source code

### Mock Installation

For an installation without using the OCI services, use the following:

```bash
helm install mushop --name mymushop \
    --set global.mock.service=all
```

### Dev installation

The default chart installation creates an Ingress resource for development (i.e. simple Ingress, without the DNS and need for Prod/Staging secrets).

Before installing the chart, you need to copy the secrets (wallet files and OCI key for streams and the service broker) to a couple of places in the chart. Check the README.md in `secrets` folder under `carts` and `orders` as well as root chart.

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
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
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
