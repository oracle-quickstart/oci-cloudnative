---
title: "OCI Health Checks"
date: 2020-10-26 T16:04:15-06:00
draft: false
weight: 100
tags:
  - OCI Health Checks
  - OCI Observability
---


## Introduction

Monitors the health of IP addresses and hostnames, as measured from geographic vantage points of your choosing, using HTTP and ping probes. After configuring a health check, you can view the monitor's results. The results include the location from which the host was monitored, the availability of the endpoint, and the date and time the test was performed.

## Pre-Requisites

Deploy [MuShop]({{< ref "quickstart/kubernetes.md" >}})

## Create Oracle Cloud Infrastructure Health Checks

Navigate to ```Monitoring -> HealthChecks -> Create HealthChecks```

![OKE Cluster Metrics](../images/create-healthcheck.png)

{{% alert style="primary" icon="warning" %}}
Target will be IP of ingress controller
```
kubectl get svc \
	mushop-utils-ingress-nginx-controller \
	--namespace mushop-utilities
```
{{% /alert %}}
	
## Verifying Oracle Cloud Infrastructure Health Check Results

Navigate to ```Monitoring -> HealthChecks -> <Your_HealthChecks_Name> -> HealthChecks History```


![OKE Cluster Metrics](../images/view-healthcheck.png)

## Observe HTTP metric

Navigate to ```Monitoring -> HealthChecks -> <Your_HealthChecks_Name> -> Metrics```

Observe some of the Http metrics. For metric details [refer](https://docs.cloud.oracle.com/en-us/iaas/Content/HealthChecks/Reference/metricsalarms.htm)

![OKE HTTP Metrics](../images/healthcheck-metric.png)

{{% alert style="primary" icon="warning" %}}
With every metric you have the ability to set Alarms to get notified on the metrics of concern.
{{% /alert %}}

Additionally, you can view these metrics under ```Monitoring -> Service Metrics -> Metric namespace = oci_healthchecks```

