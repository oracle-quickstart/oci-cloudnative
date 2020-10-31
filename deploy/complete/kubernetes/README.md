# Deploy in Kubernetes

## Deploy using Helm Chart

Refer to [helm-chart](../helm-chart/README.md)

## Prerequisites

### Install Ingress Controller

> NOTE: There are several options for ingress controllers in K8S. This demo uses the common `ingress-nginx`

```text
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/cloud-generic.yaml
```

```bash
kubectl -n ingress-nginx get svc
```

### Enable the monitoring capability by adding your OCI credentials:

```bash
kubectl create secret generic monitoring-secret \
--from-literal=compartment_id="<your compartment_id>" \
--from-literal=tenant_id="<your tenancy_id>" \
--from-literal=user_id="<your user_id>" \
--from-literal=fingerprint="<your fingerprint>" \
--from-literal=passphrase="<your passphrase>" \
--from-literal=monitoring_endpoint="<your monitoring endpoint>" \
--from-literal=region="<your region>" \
--from-file=apikey=<your api_key.pem>
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
