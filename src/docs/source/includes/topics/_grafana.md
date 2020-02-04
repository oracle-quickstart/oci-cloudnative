## Prometheus and Grafana Monitoring

Prometheus and Grafana are installed part of the [`setup`](#setup) umbrella helm chart.
Revisit the application charts and connect to some Grafana dashboards:

1. List helm releases:

    ```text
    helm list --all-namespaces
    ```

    ```text
    NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
    mushop                  mushop                  1               2020-01-31 21:14:48.511917 -0600 CST    deployed        mushop-0.1.0                    1.0         
    mushop-utility          mushop-utilities        1               2020-01-31 20:32:05.864769 -0600 CST    deployed        mushop-setup-0.0.1              1.0          
    ```

1. Get the Grafana outputs from the `mushop-utility` (setup chart) installation:

    ```text
    helm status status mushop-utility --namespace mushop-utilities

    ## Grafana...
    ```

1. Get the auto-generated Grafana `admin` password:

    ```text
    kubectl get secret -n mushop-utilities mushop-utility-grafana \
     -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

1. Connect to the [dashboard](http://localhost:3000) with `admin`/`<password>`:

    ```text
    kubectl port-forward -n mushop-utilities \
      svc/mushop-utility-grafana 3000:80
    ```

1. Import [dashboards](https://grafana.com/grafana/dashboards) from Grafana:
    - [Kubernetes Cluster](https://grafana.com/grafana/dashboards/6417)
    - [Kubernetes Pods](https://grafana.com/grafana/dashboards/6336)

<aside class="notice">
  Many community dashboards exist, those above are some basic recommendations
</aside>
