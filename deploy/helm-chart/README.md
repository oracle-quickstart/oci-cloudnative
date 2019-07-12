# MuShop Helm Chart

The `mushop` Helm chart can be used to install all components of the MuShop to the Kubernetes cluster.

## Prerequisites

- Kubernetes cluster
- Helm

## Dev installation

The default chart installation creates an Ingress resource for development (i.e. simple Ingress, without the DNS and need for Prod/Staging secrets). This can be changed by setting the `ingressDev.enabled=false`. Similarly, if you want to deploy Ingress with the hosts and certificates set up, you need to set the `ingressDns.enabled=true` (don't forget to set `ingressDev.enabled=false` as well). In the future, we will provide a separate set of values file for Dev and Prod deployments.

Before installing the chart, store the contents of your OCI API key in an environment variable:

```bash
export OCI_KEY=$(cat <your home folder>/.oci/oci_api_key.pem)
```

To install the chart, run the command below. Make sure to replace the release name and provide the passwords and OCI settings:

```bash
helm install mushop --name mymushop \
    --set catalogue.secrets.oadbPassword=xxxxxx \
    --set carts.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.oadbPassword=xxxxxx \
    --set secrets.oci.compartmentId=<your compartment id> \
    --set secrets.oci.tenantId=<your tenant id> \
    --set secrets.oci.userId=<your user id> \
    --set secrets.oci.region=<your region> \
    --set secrets.oci.apiKey="$OCI_KEY"
```

If you want to troubleshoot the chart, add the `--dry-run` and `--debug` flags and re-run the command again. For example:

```bash
helm install mushop --dry-run --debug --name mymushop \
    --set catalogue.secrets.oadbPassword=xxxxxx \
    --set carts.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.oadbPassword=xxxxxx \
    --set secrets.oci.compartmentId=<your compartment id> \
    --set secrets.oci.tenantId=<your tenant id> \
    --set secrets.oci.userId=<your user id> \
    --set secrets.oci.region=<your region> \
    --set secrets.oci.apiKey="$OCI_KEY"
```

### Installing HPA for API and Storefront

Optionally, you can enable HPA for API and Storefront components by setting the `api.hpa.enabled=true` and/or `storefront.hpa.enabled=true` and passing them to the helm install command like this:

```bash
helm install --dry-run --debug mushop --name mymushop \
    --set catalogue.secrets.oadbPassword=xxxxxx \
    --set carts.secrets.oadbPassword=xxxxxx \
    --set orders.secrets.oadbPassword=xxxxxx \
    --set secrets.oci.compartmentId=<your compartment id> \
    --set secrets.oci.tenantId=<your tenant id> \
    --set secrets.oci.userId=<your user id> \
    --set secrets.oci.region=<your region> \
    --set secrets.oci.apiKey="$OCI_KEY" \
    --set api.hpa.enabled=true \
    --set storefront.hpa.enabled=true
```

## Prod/Staging installation

For prod/staging installation, you need to deploy the following secrets, before running the Helm install command:

```
letsencrypt-prod
mushop-tls-prod-secret
```