---
title: "Grafana Monitoring"
date: 2020-03-09T16:05:08-06:00
weight: 40
---

## Prometheus and Grafana

Prometheus and Grafana are installed part of the [`setup`](#setup) umbrella helm chart.
Revisit the application charts and connect to some Grafana dashboards:

1. List helm releases:

    ```text
    helm list --all-namespaces
    ```

    ```text
    NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
    mushop                  mushop                  1               2020-01-31 21:14:48.511917 -0600 CST    deployed        mushop-0.1.0                    1.0
    mushop-utils            mushop-utilities        1               2020-01-31 20:32:05.864769 -0600 CST    deployed        mushop-setup-0.0.1              1.0
    ```

1. Get the Grafana outputs from the `mushop-utils` (`setup` chart) installation:

    ```text
    helm status mushop-utils --namespace mushop-utilities

    ## Grafana...
    # ...
    ```

1. Get the auto-generated Grafana `admin` password:

    ```text
    kubectl get secret -n mushop-utilities mushop-utils-grafana \
     -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

1. Connect to the [dashboard](http://localhost:3000) with `admin`/`<password>`:

    ```text
    kubectl port-forward -n mushop-utilities \
      svc/mushop-utils-grafana 3000:80
    ```

    > The Grafana dashboard will be accessible on [http://localhost:3000](http://localhost:3000)

1. Import [dashboards](https://grafana.com/grafana/dashboards) from Grafana:

    - [Kubernetes Cluster](https://grafana.com/grafana/dashboards/6417)
    - [Kubernetes Pods](https://grafana.com/grafana/dashboards/6336)
    - [Spring Boot Applications](https://grafana.com/grafana/dashboards/12464)

    {{% alert style="primary" icon="info" %}}
    Many community dashboards exist, those above are some basic recommendations
    {{% /alert %}}

