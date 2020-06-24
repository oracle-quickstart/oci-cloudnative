MuShop provides an umbrella helm chart called `setup`, which includes several
_recommended_ installations on the cluster. These represent common 3rd party
services, which integrate with Oracle Cloud Infrastructure or enable certain
application features.

| Chart | Purpose | Option |
|---|---|---|
| [Prometheus](https://github.com/helm/charts/blob/master/stable/prometheus/README.md) | Service metrics aggregation | `prometheus.enabled` |
| [Grafana](https://github.com/helm/charts/blob/master/stable/grafana/README.md) | Infrastructure/service visualization dashboards | `grafana.enabled` |
| [Metrics Server](https://github.com/helm/charts/blob/master/stable/metrics-server/README.md) | Support for Horizontal Pod Autoscaling | `metrics-server.enabled` |
| [Ingress Nginx](https://kubernetes.github.io/ingress-nginx/) | Ingress controller and public Load Balancer | `ingress-nginx.enabled` |
| [Service Catalog](https://github.com/kubernetes-sigs/service-catalog/blob/master/charts/catalog/README.md) | Service Catalog chart utilized by Oracle Service Broker | `catalog.enabled` |
| [Cert Manager](https://github.com/jetstack/cert-manager/blob/master/README.md) | x509 certificate management for Kubernetes | `cert-manager.enabled` |
| [Jenkins](https://github.com/helm/charts/blob/master/stable/jenkins/README.md) | Jenkins automation server on Kubernetes | `jenkins.enabled` |

> Dependencies installed with `setup` chart. **NOTE** as these are very common installations, each may be disabled as needed to resolve conflicts.

From `deploy/complete/helm-chart` directory:

1. Install chart dependencies:

    ```shell
    helm dependency update setup
    ```

1. Install `setup` chart:

    ```shell--helm2
    helm install setup \
      --name mushop-utils \
      --namespace mushop-utilities
    ```

    ```shell--helm3
    kubectl create ns mushop-utilities
    ```

    ```shell--helm3
    helm install mushop-utils setup \
      --namespace mushop-utilities
    ```
1. **NOTE** The Jenkins automation server is disabled by default in the `values.yaml`, and can be enabled by setting `jenkins.enabled` to `true` in the file or using the CLI.
   ```shell--helm3
    helm install mushop-utils setup \
      --namespace mushop-utilities \
      --set jenkins.enabled=true
   ```

1. **NOTE** the public `EXTERNAL-IP` assigned to the ingress controller load balancer:

    ```shell
    kubectl get svc mushop-utils-ingress-nginx-controller \
      --namespace mushop-utilities
    ```
