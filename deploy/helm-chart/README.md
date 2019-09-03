# MuShop Helm Chart

The `mushop` Helm chart can be used to install all components of the MuShop to the Kubernetes cluster.

## Prerequisites

- Kubernetes cluster
- Helm
- Secrets (Wallet/OCI) in the `/secrets` folders under root, `carts` and `orders` charts

## Mock Installation

For local installation without OCI, use the following:

```text
helm install mushop --name mymushop \
    --set global.mock.service=all
```

## Dev installation

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

## Prod/Test installation

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
helm install --dry-run --debug mushop -f /mushop/values-prod.yaml --name mymushop \
    --set carts.secrets.oadbPassword=xxxxxx \
    --set carts.secrets.trustPass=xxxxxx \
    --set carts.secrets.keyPass=xxxxxx \
    --set catalogue.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.trustPass=xxxxxx \
    --set orders.secrets.keyPass=xxxxxx \
    --set secrets.oci.compartmentId=<your compartment id> \
    --set secrets.oci.tenantId=<your tenant id> \
    --set secrets.oci.fingerprint=<api_key fingerprint> \
    --set secrets.oci.userId=<your user id> \
    --set secrets.oci.region=<your region> \
    --set secrets.oci.passphrase=<api_key passphrase>
```

## Creating all/individual YAML files

If you don't want to deploy the charts, you can also render the template and get all YAML files by running the `template` command and providing an output directory:

```bash
helm template mushop --output-dir [SOME_DIR] --name mymushop \
    --set carts.secrets.oadbPassword=xxxxxx \
    --set carts.secrets.trustPass=xxxxxx \
    --set carts.secrets.keyPass=xxxxxx \
    --set catalogue.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.trustPass=xxxxxx \
    --set orders.secrets.keyPass=xxxxxx \
    --set secrets.oci.compartmentId=<your compartment id> \
    --set secrets.oci.tenantId=<your tenant id> \
    --set secrets.oci.fingerprint=<api_key fingerprint> \
    --set secrets.oci.userId=<your user id> \
    --set secrets.oci.region=<your region> \
    --set secrets.oci.passphrase=<api_key passphrase>
```
