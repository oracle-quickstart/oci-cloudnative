---
title: "Istio Service Mesh"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 80
tags:
  - Istio
  - Service Mesh
  - Kiali
---

{{% alert style="danger" icon="warning" %}}
Note that this is **OPTIONAL**. If you don't want to install Istio service mesh, skip to the [deployment]({{< ref "cloud/deployment.md" >}}) section. Additionally, you don't need to install Grafana, Prometheus or the Ingress controller from the `setup` chart as they are already included in the Istio installation.
{{% /alert %}}

In this section you can install and configure Istio service mesh. The mesh needs to be installed before you deploy Mushop for the service mesh proxies to get injected next to each Mushop service.

These sidecar proxies intercept the traffic between services and collect data on all requests as well as allow scenarios such as traffic routing and failure injection.

## Download and install Istio

1. Download the latest Istio release (`1.4.6` at the time of writing this):

    ```shell
    curl -L https://istio.io/downloadIstio | sh -
    ```

1. Go to the `istio-1.4.6` folder and add the `istioctl` to your path:

    ```shell
    export PATH=$PWD/bin:$PATH
    ```

    Before you continue with Istio installation, run the `verify-install` command to make sure Istio can be installed on your cluster:

    ```shell
    $ istioctl verify-install
    ...
    Install Pre-Check passed! The cluster is ready for Istio installation.
    ```

    If you get the `Pre-Check passed` message, you can continue.  

1. Install the Istio `demo` profile:

    ```shell
    istioctl manifest apply --set profile=demo
    ```

    {{% alert style="primary" icon="warning" %}}
    Istio supports different installation profiles such as _default_, _demo_, _minimal_,
    _sds_ and _remote_. In this lab we will be using the _demo_ installation as it contains all components and it is designed to showcase Istio functionality. Note that _demo_
    profile is **NOT** an appropriate installation for production.
    {{% /alert %}}

    The output of the above command should look something like this:

    ```text
    $ istioctl manifest apply --set profile=demo
    - Applying manifest for component Base...
    ✔ Finished applying manifest for component Base.
    - Applying manifest for component EgressGateway...
    - Applying manifest for component Prometheus...
    - Applying manifest for component Pilot...
    - Applying manifest for component Tracing...
    - Applying manifest for component Citadel...
    - Applying manifest for component Injector...
    - Applying manifest for component Galley...
    - Applying manifest for component Kiali...
    - Applying manifest for component IngressGateway...
    - Applying manifest for component Policy...
    - Applying manifest for component Telemetry...
    - Applying manifest for component Grafana...
    ✔ Finished applying manifest for component Galley.
    ✔ Finished applying manifest for component Kiali.
    ✔ Finished applying manifest for component Injector.
    ✔ Finished applying manifest for component Prometheus.
    ✔ Finished applying manifest for component Citadel.
    ✔ Finished applying manifest for component Pilot.
    ✔ Finished applying manifest for component Policy.
    ✔ Finished applying manifest for component IngressGateway.
    ✔ Finished applying manifest for component Tracing.
    ✔ Finished applying manifest for component EgressGateway.
    ✔ Finished applying manifest for component Telemetry.
    ✔ Finished applying manifest for component Grafana.
    ✔ Installation complete
    ```

    You also need to run `kubectl get pods -n istio-system` and ensure all pods are in the running state (the value of the `STATUS` column for each pod should be `Running`)

    Before continuing with the Mushop deployment, you also need to label the `mushop` namespace in order for Istio to automatically inject the Envoy sidecar proxy next to each Mushop service.

1. Create the `mushop` namespace:

```shell
kubectl create ns mushop
```

1. Label the namespace with `istio-injection=enabled`:

```shell
kubectl label namespace mushop istio-injection=enabled
```

1. Follow the instructions for [deploying Mushop](#deployment). 

## Creating Istio resources

In order to configure the traffic routing and the ingress gateway, you will need to deploy a Gateway resource and a VirtualService resource.

1. Deploy a Gateway resource:

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

1. Deploy a VirtualService:

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

1. Open a browser with the `EXTERNAL-IP` of the Instio ingress gateway:

    ```shell
    kubectl get svc istio-ingressgateway \
      --namespace istio-system
    ```

    > Locating `EXTERNAL-IP` for Istio Ingress Gateway. **NOTE** this will be
    [localhost](https://localhost) on local clusters.

## Kiali Dashboard

Kiali is a service mesh observability tool that allows you to understand the structure of your service mesh, visualize the service inside the mesh and provides the health of the mesh. Additionally, you can view detailed metrics using Grafana integration and distribute tracing with Jaeger integration.

1. From the terminal, open Kiali dashboard

    ```shell
    istioctl dashboard kiali
    ```

1. Click the **Graph** option from the sidebar.

1. From the dropdown select the *mushop* namespace.

1. You should see a service graph that looks similar to the figure below;

    ![Kiali - service graph](../images/mesh/sm-kiali-graph.png)

## Cleanup

Uninstall Istio by passing the generated manifests into `kubectl delete`

```shell
istioctl manifest generate --set profile=demo | kubectl delete -f -
```
