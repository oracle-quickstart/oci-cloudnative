#

MuShop provides an umbrella helm chart called `setup`, which includes several
_recommended_ installations on the cluster. These represent common 3rd party
services, which integrate with Oracle Cloud Infrastructure or enable certain
application features.

| Chart | Purpose | Option | Default
|---|---|---|---|
| [Prometheus](https://github.com/helm/charts/blob/master/stable/prometheus/README.md) | Service metrics aggregation | `prometheus.enabled` | true |
| [Grafana](https://github.com/helm/charts/blob/master/stable/grafana/README.md) | Infrastructure/service visualization dashboards | `grafana.enabled` | true |
| [Metrics Server](https://github.com/helm/charts/blob/master/stable/metrics-server/README.md) | Support for Horizontal Pod Autoscaling | `metrics-server.enabled` | true |
| [Ingress Nginx](https://kubernetes.github.io/ingress-nginx/) | Ingress controller and public Load Balancer | `ingress-nginx.enabled` | true |
| [Cert Manager](https://github.com/jetstack/cert-manager/blob/master/README.md) | x509 certificate management for Kubernetes | `cert-manager.enabled` | true |
| [Service Catalog](https://github.com/kubernetes-sigs/service-catalog/blob/master/charts/catalog/README.md) | (Archived) Service Catalog chart utilized by Oracle Service Broker | `catalog.enabled` | false |
| [Jenkins](https://github.com/helm/charts/blob/master/stable/jenkins/README.md) | Jenkins automation server on Kubernetes | `jenkins.enabled` | false |

> Dependencies installed with `setup` chart. **NOTE** as these are very common installations, each may be disabled as needed to resolve conflicts.

From `deploy/complete/helm-chart` directory:

<!-- 1. Install chart dependencies:

    ```shell
    helm dependency update setup
    ``` -->

1. Install `setup` chart:

    ```shell--helm2
    helm install setup \
      --name mushop-utils \
      --namespace mushop-utilities
    ```

    <!-- ```shell--helm3
    kubectl create ns mushop-utilities
    ``` -->

    ```shell--helm3
    helm upgrade --install mushop-utils setup \
      --dependency-update \
      --namespace mushop-utilities \
      --create-namespace
    ```

    > **OPTIONAL** In case you are provisioning ATP, Stream, and Object Storage with **OCI Service Broker**. In that case, you should enable the Service Catalog `catalog.enabled` to `true` in `values.yaml` or by adding the command line flag `--set catalog.enabled=true` in the `helm install` command above.

    ```shell--helm3
    helm upgrade --install mushop-utils setup \
      --dependency-update \
      --namespace mushop-utilities \
      --create-namespace \
      --set catalog.enabled=true
    ```

    > **OPTIONAL** The Jenkins automation server can be enabled by setting `jenkins.enabled` to `true` in `values.yaml` or by adding the command line flag `--set jenkins.enabled=true` in the `helm install` command above.

    ```shell--helm3
    helm upgrade --install mushop-utils setup \
      --dependency-update \
      --namespace mushop-utilities \
      --create-namespace \
      --set jenkins.enabled=true
    ```

1. **NOTE** the public `EXTERNAL-IP` assigned to the ingress controller load balancer:

    ```shell
    kubectl get svc mushop-utils-ingress-nginx-controller \
      --namespace mushop-utilities
    ```
