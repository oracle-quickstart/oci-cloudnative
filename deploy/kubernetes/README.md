# Deploy in Kubernetes

## Deploy using Helm Chart

1. Store the contents of your OCI API key in an environment variable:

```bash
export OCI_KEY=$(cat <your home folder>/.oci/oci_api_key.pem)
```

2. Install the Helm chart by providing necessary values:

```bash
helm install --dry-run --debug mushop --name mymushop \
    --set secrets.catalogue.oadbPassword=xxxxxx \
    --set secrets.carts.oadbPassword=xxxxxx \
    --set secrets.orders.oadbPassword=xxxxxx\
    --set secrets.oci.compartmentId=<your compartment id>
    --set secrets.oci.tenantId=<your tenant id>
    --set secrets.oci.userId=<your user id>
    --set secrets.oci.region=<your region>
    --set secrets.oci.apiKey="$OCI_KEY"
```




## Prerequisites

### Install Ingress Controller

> NOTE: There are several options for ingress controllers in K8S. This demo uses the common `ingress-nginx`

```text
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
```

### Configure Secrets

Secret for ATP access:

```text
kubectl create secret generic atp-secret \
--from-literal=catalogue_oadb_user="catalogue_user" \
--from-literal=catalogue_oadb_pw="xxxxxx" \
--from-literal=catalogue_oadb_service="mcatalogue_tp" \
--from-literal=carts_oadb_user="carts_user" \
--from-literal=carts_oadb_pw="xxxxxx" \
--from-literal=carts_oadb_service="mcarts_tp" \
--from-literal=orders_oadb_user="orders_user" \
--from-literal=orders_oadb_pw="xxxxxx" \
--from-literal=orders_oadb_service="morders_tp"
```

Secret for OSS access:

```text
kubectl create secret generic streams-secret \
--from-literal=oci_compartment_id="<your compartment id>" \
--from-literal=oci_tenant_id="<your tenant id>" \
--from-literal=oci_user_id="<your user id>" \
--from-literal=oci_fingerprint="<your API key fingetprint>" \
--from-literal=oci_region="<your region>" \
--from-file=oci_api_key=\<your home folder>/.oci/oci_api_key.pem \
--from-literal=oci_pass_phrase="[your key passphrase]"
```
## Deploy

### Create Runtime in K8S

```text
kubectl apply -f mushop.yaml
```

> Verify with `kubectl get po`

## Expose

### Option A: kubectl port-forward

Best for testing deployments on a single cluster without host-specific ingress
rules. This exposes the edge service on `localhost` where `kubectl` is executed.

```text
kubectl port-forward svc/edge 8000:80
```

Open browser [http://localhost:8000](http://localhost:8000);

### Option B: K8S Ingress

Better for development environments with nginx ingress controller installed.
This involves creating the Ingress defined within `ingress/mushop-dev.yaml`

```text
kubectl apply -f ingress/mushop-dev.yaml
```

The application will become available on [https://localhost](https://localhost)
_(with self-signed SSL)_