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

In this section we will demonstrate canary deployment use case with MuShop Application.

One of the benefits of the Istio project is that it provides the control needed to deploy canary services. The idea behind canary deployment (or rollout) is to introduce a new version of a service by first testing it using a small percentage of user traffic, and then if all goes well, increase, possibly gradually in increments, the percentage while simultaneously phasing out the old version. If anything goes wrong along the way, we abort and rollback to the previous version. In its simplest form, the traffic sent to the canary version is a randomly selected percentage of requests, but in more sophisticated schemes it can be based on the region, user, or other properties of the request. Read more details [here](https://istio.io/latest/blog/2017/0.1-canary/) 

We shall demonstrate the simplest canary deployment by using two versions of storefront microservice (storefront:original and storefront:beta) and would split traffic between the two. 

- storefront:original would be the original page which does not have the reviews feature.
- storefront:beta would have a new feature called "reviews" displayed on the UI which would let the user's provide review for their products. 

Note: The builds storefront:original and storefront:beta naming conventions are used here for easier understanding. 
Later during the procedure we will use the exact build version. 

Lets look at the diagram which would explain the same

![MuShop Canary Deployment](../images/mesh/mushop-canary.png)

{{% alert style="warning" icon="warning" %}}
The path between users and storefront has many layers ( DNS -> WAF -> LB -> INGRESS -> Router -> Storefront), The above figure shown is high level. Refer https://mushop.ateam.cloud/about.html for more details.
{{% /alert %}}

We would configure and run the storefront services in an Istio-enabled environment, with Envoy sidecars injected along side each service. We configure the Istio http routing by creating a VirtualService and Destination rules. Storefront images are available on the Oracle Cloud Infrastructure Registry. We would use them to create a kubernetes deployment.

## Pre-Requisites

Deploy [Mushop]({{< ref "quickstart/kubernetes.md" >}})

Download and install [Istio Service Mesh]({{< ref "istio.md" >}})

## Deploy storefront beta
 
 - Create a deployment with the below config and name it mushop-storefrontv2.
   
   Note: We will use the same labels as that of storefront original.

  ```shell--macos-linux
    cat << EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app.kubernetes.io/instance: mushop
        app.kubernetes.io/name: storefront
      name: mushop-storefrontv2
      namespace: mushop
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: storefront
          app.kubernetes.io/instance: mushop
          app.kubernetes.io/name: storefront
      template:
        metadata:
          labels:
            app: storefront
            app.kubernetes.io/instance: mushop
            app.kubernetes.io/name: storefront
            version: 2.1.3-beta.1
        spec:
          containers:
          - image: iad.ocir.io/oracle/ateam/mushop-storefront:2.1.3-beta.1
            imagePullPolicy: Always
            name: storefront
  EOF
  ```

  ```shell--win
  "apiVersion: apps/v1
  kind: Deployment
  metadata:
    labels:
      app.kubernetes.io/instance: mushop
      app.kubernetes.io/name: storefront
    name: mushop-storefrontv2
    namespace: mushop
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: storefront
        app.kubernetes.io/instance: mushop
        app.kubernetes.io/name: storefront
    template:
      metadata:
        labels:
          app: storefront
          app.kubernetes.io/instance: mushop
          app.kubernetes.io/name: storefront
          version: 2.1.3-beta.1
      spec:
        containers:
        - image: iad.ocir.io/oracle/ateam/mushop-storefront:2.1.3-beta.1
          imagePullPolicy: Always
          name: storefront" | kubectl apply -f -
  ```


## Create Istio resources

- Deploy a Gateway resource

  ```shell--macos-linux
    cat << EOF | kubectl apply -f -
    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: gateway
      namespace: mushop
    spec:
      selector:
        istio: ingressgateway
      servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
          hosts:
            - '*'
  EOF
    ```

    ```shell--win
    "apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: gateway
      namespace: mushop
    spec:
      selector:
        istio: ingressgateway
      servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
          hosts:
            - '*'" | kubectl apply -f -
    ```

- Deploy a VirtualService and DestinationRules
  
  ```shell--macos-linux
    cat <<EOF | kubectl apply -f -
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: edge
      namespace: mushop
    spec:
      hosts:
        - '*'
      gateways:
        - gateway
      http:
      - match:
        - uri:
            prefix: /api
        route:
        - destination:
            host: mushop-api.mushop.svc.cluster.local
      - match:
        - uri:
            prefix: /assets
        rewrite:
          uri: /
        route:
        - destination:
            host: mushop-assets.mushop.svc.cluster.local
      - route:
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            subset: original
          weight: 50
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            subset: beta
          weight: 50
  EOF
    ```

    ```shell--win
    "apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: edge
      namespace: mushop
    spec:
      hosts:
        - '*'
      gateways:
        - gateway
      http:
      - match:
        - uri:
            prefix: /api
        route:
        - destination:
            host: mushop-api.mushop.svc.cluster.local
      - match:
        - uri:
            prefix: /assets
        rewrite:
          uri: /
        route:
        - destination:
            host: mushop-assets.mushop.svc.cluster.local
      - route:
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            subset: original
          weight: 50
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            subset: beta
          weight: 50 | kubectl apply -f -
    ```

   - Destination Rule
    
    ```shell--macos-linux
    cat <<EOF | k apply -f -
    apiVersion: networking.istio.io/v1alpha3
    kind: DestinationRule
    metadata:
      name: reviews-destination
    spec:
      host: mushop-storefront.mushop.svc.cluster.local
      subsets:
      - name: original
        labels:
          version: 2.1.2
      - name: beta
        labels:
          version: 2.1.3-beta.1
  EOF
    ```

    ```shell--win
    "apiVersion: networking.istio.io/v1alpha3
    kind: DestinationRule
    metadata:
      name: reviews-destination
    spec:
      host: mushop-storefront.mushop.svc.cluster.local
      subsets:
      - name: original
        labels:
          version: 2.1.2
      - name: beta
        labels:
          version: 2.1.3-beta.1" | kubectl apply -f -
    ```

- Open a browser with the EXTERNAL-IP of the Istio ingress gateway
  
  ```shell
    kubectl get svc istio-ingressgateway \
      --namespace istio-system
    ```

    > Locating `EXTERNAL-IP` for Istio Ingress Gateway. **NOTE** this will be
    [localhost](https://localhost) on local clusters.
    
## Testing

 Open a Incognito/Private window of a browser and access http://EXTERNAL-IP/.
 
 Try to refreshing the URL multiple times and you would see two different storefront UI's (original and beta) with 50% of traffic going to each.
 
{{% alert style="warning" icon="info" %}}
We can also change the percentage of traffic from 50:50 to 90:10. For more focused canary testing using Header and URI matching [refer](https://istio.io/latest/blog/2017/0.1-canary/#focused-canary-testing) 

{{% /alert %}}


## Noticing the issues

- Review page ratings star icon wont fill when clicked. 

## Roll Back

- We would change the routing back to default as below

  ```shell--macos-linux
    cat <<EOF | kubectl apply -f -
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: edge
      namespace: mushop
    spec:
      hosts:
        - '*'
      gateways:
        - gateway
      http:
      - match:
        - uri:
            prefix: /api
        route:
        - destination:
            host: mushop-api.mushop.svc.cluster.local
      - match:
        - uri:
            prefix: /assets
        rewrite:
          uri: /
        route:
        - destination:
            host: mushop-assets.mushop.svc.cluster.local
      - route:
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            port:
              number: 80
  EOF
    ```

    ```shell--win
    "apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: edge
      namespace: mushop
    spec:
      hosts:
        - '*'
      gateways:
        - gateway
      http:
      - match:
        - uri:
            prefix: /api
        route:
        - destination:
            host: mushop-api.mushop.svc.cluster.local
      - match:
        - uri:
            prefix: /assets
        rewrite:
          uri: /
        route:
        - destination:
            host: mushop-assets.mushop.svc.cluster.local
      - route:
        - destination:
            host: mushop-storefront.mushop.svc.cluster.local
            port:
              number: 80" | kubectl apply -f -
    ```

## Cleanup

Uninstall Istio by passing the generated manifests into `kubectl delete`

```shell
istioctl manifest generate --set profile=demo | kubectl delete -f -
```
Mushop Cleanup [refer]({{< ref "cleanup/_index.md" >}})

