---
title: "Setup"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 1
tags:
  - mushop setup
---

## Pre-requisites

### Create kubernetes namespace

```bash
kubectl create namespace mushop
```

## Deploy

```
cd deploy/complete/kubernetes
```

```text
kubectl -n mushop apply -f mushop.yaml
```

Verify if all the pods are in running status 

```text
kubectl -n mushop get pods
```

## Expose

### Option A: kubectl port-forward

This command exposes the edge service on `localhost`.

```text
kubectl -n mushop port-forward svc/edge 8000:80
```

Open browser [http://localhost:8000](http://localhost:8000);
