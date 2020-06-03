---
title: "Canary Deployment"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 90
tags:
  - Canary
  - Patching
---

{{% alert style="warning" icon="warning" %}}
Note that this is **OPTIONAL**. This section is only applicable if you have completed [Istio service mesh]({{< ref "istio.md" >}}) section. 
{{% /alert %}}

## Introduction

In this section we will demonstrate canary deployment use case on MuShop Application.

We shall have two versions on storefront microservice (storefront:v1 and storefront:betav1) and would split traffic between the two versions. 
- storefront:betav1 would have a new feature called "reviews" displayed on the UI which would let the user's provide review of their products. 
- storefront:v1 would not have the reviews feature.

Lets look at the diagram which would explain the same

![MuShop Canary Deployment](../images/mesh/mushop-canary.png)

{{% alert style="warning" icon="warning" %}}
The path between users and storefront has many layers (DNS->WAF->LB->INGRESS->Router->Storefront). Refer https://mushop.ateam.cloud/about.html
{{% /alert %}}

In this exercise we will:

1. Access the MuShop application without the Review feature.
1. Deploy Storefront:betav1 microservice on Kubernetes.
1. Configure Istio Gateway and VirtualService (http routing).
1. Access the Mushop application with the Review feature.
1. Determine the Issues with the Review feature.
1. RollBack the Canary Deployment.


We would configure and run the storefront services in an Istio-enabled environment, with Envoy sidecars injected along side each service. We configure the Istio http routing by creating a VirtualService object. Storefront images are available on the Oracle Cloud Infrastructure Registry. We would use them create a kubernetes deployment.

## Pre-Requisites:

Download and install [Istio Service Mesh]({{< ref "istio.md" >}})

## Creating Istio resources

1. Deploy a Gateway resource
<To Do>
2. Deploy a VirtualService
<To Do>
3. Open a browser with the EXTERNAL-IP of the Istio ingress gateway
<To Do>

## Notice the issues:
- Review page ratings star icon wont fill when clicked. 
- On the main page the ratings icon does not fit within the product cards.

## Roll Back
<To Do>

## Cleanup
<To Do>


