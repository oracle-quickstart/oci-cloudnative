# MuShop Helm Chart

The `mushop` Helm chart can be used to install all components of the MuShop to the Kubernetes cluster.

## Prerequisites

- Kubernetes cluster
- Helm

## Dev installation

The default chart installation creates an Ingress resource for development (i.e. simple Ingress, without the DNS and need for Prod/Staging secrets). This can be changed by setting the `ingressDev.enabled=false`. Similarly, if you want to deploy Ingress with the hosts and certificates set up, you need to set the `ingressDns.enabled=true` (don't forget to set `ingressDev.enabled=false` as well). In the future, we will provide a separate set of values file for Dev and Prod deployments.

Before installing the chart, copy your OCI API key to `secrets/oci_api_key.pem` file - this file is read when Helm chart is being installed.

To install the chart, run the command below. Make sure to replace the release name and provide the passwords and OCI settings:

```bash
helm install mushop --name mymushop \
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

If you want to troubleshoot the chart, add the `--dry-run` and `--debug` flags and re-run the command again. For example:

```bash
helm install mushop --dry-run --debug --name mymushop \
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

### Installing HPA for components

Optionally, you can enable HPA for components by setting the `hpa.enabled` property to `true`. For example: `api.hpa.enabled=true`, and then pass it to the install command:

```bash
helm install --dry-run --debug mushop --name mymushop \
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
    --set secrets.oci.passphrase=<api_key passphrase> \
    --set api.hpa.enabled=true \
```

## Prod/Test installation

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