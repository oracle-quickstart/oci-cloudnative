# Deploy in Kubernetes

## Deploy using Helm Chart

Refer to [helm-chart](../helm-chart/README.md)

## Prerequisites

### Install Ingress Controller

> NOTE: There are several options for ingress controllers in K8S. This demo uses the common `ingress-nginx`

```text
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
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
