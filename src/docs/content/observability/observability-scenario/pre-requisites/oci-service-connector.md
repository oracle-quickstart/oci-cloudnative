---
title: "OCI Service Connector Hub"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 4
tags:
  - service connector hub
---

### Introduction

Service Connector Hub orchestrates data movement between services in Oracle Cloud Infrastructure.

Data is moved using service connectors. A service connector specifies the source service that contains the data to be moved, tasks to run on the data, and the target service for delivery of data when tasks are complete.


### Pre-Requisites

Deploy [OCI Logging]({{< ref "oci-logging.md" >}})

## Create Oracle Cloud Infrastructure (OCI) Service Connector

Navigate to ```Logging -> Service Connectors -> Create Connector```

    Name: <Service Connector Name>
    Description: <Service Connector Description>
    source: Logging
    target: Monitoring
    loggroups: <LogGroupName>
    logs: <LogName>
    metricnamespace: <MetricNameSpace>
    metric: <MetricName>

![Service Connector](../../../images/service-connector.png)