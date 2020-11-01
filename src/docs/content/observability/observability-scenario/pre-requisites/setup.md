---
title: "Setup"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 1
tags:
  - mushop setup
---

## Pre-requisites

### Install Ingress Controller

```bash
kubectl create namespace mushop
```
```text

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/cloud-generic.yaml
```

### Create a Secret for OCI Monitoring

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

```
cd deploy/complete/kubernetes
```

```text
kubectl apply -f mushop.yaml
```

Verify if all the pods are in running status 
```text
kubectl -n mushop get pods
```

## Expose

### Option A: kubectl port-forward

Best for testing deployments on a single cluster without host-specific ingress
rules. This exposes the edge service on `localhost` where `kubectl` is executed.

```text
kubectl port-forward svc/edge 8000:80
```

Open browser [http://localhost:8000](http://localhost:8000);
