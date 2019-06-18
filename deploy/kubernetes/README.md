# Deploy in Kubernetes

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

```text
kubectl apply -f mushop.yaml
```
