# Extras

## Metrics

Prometheus and Grafana are installed part of the [`setup`](#setup) umbrella helm chart.
Revisit the application charts and connect to some Grafana dashboards:

1. List helm releases:

    ```text
    helm list
    ```

    ```text
    NAME          REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
    mushop-setup  1               Tue Nov 12 06:12:45 2019        DEPLOYED        mushop-setup-0.0.1      1.0             mushop-setup
    mushop        1               Wed Nov 13 20:23:28 2019        DEPLOYED        mushop-0.1.0            1.0             mushop
    ```

1. Get the Grafana outputs from the `mushop-setup` installation:

    ```text
    helm status mushop-setup

    ## Grafana...
    ```

1. Get the auto-generated Grafana `admin` password:

    ```text
    kubectl get secret -n mushop-setup mushop-setup-grafana \
      -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

1. Connect to the [dashboard](http://localhost:3000) with `admin`/`<password>`:

    ```text
    kubectl port-forward -n mushop-setup \
      svc/mushop-setup-grafana 3000:80
    ```

1. Import [dashboards](https://grafana.com/grafana/dashboards) from Grafana:
    - [Kubernetes Cluster](https://grafana.com/grafana/dashboards/6417)
    - [Kubernetes Pods](https://grafana.com/grafana/dashboards/6336)

    > Many community dashboards exist, those above are some basic recommendations
