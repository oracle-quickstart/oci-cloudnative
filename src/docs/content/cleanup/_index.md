---
title: "Cleanup"
date: 2020-03-09T16:06:00-06:00
weight: 1000
disablePrevNext: true
tags:
  - Cleanup
  - Uninstall
  - Deprovision
---

The following list represents cleanup operations, which may vary
depending on the actions performed for setup and deployment of MuShop.

- List any `helm` releases that may have been installed:

    ```shell--helm2
    helm list
    ```

    ```shell--helm3
    helm list --all-namespaces
    ```

    ```text
    NAME                    NAMESPACE               REVISION        UPDATED                                 STATUS          CHART                           APP VERSION   
    mushop                  mushop                  1               2020-01-31 21:14:48.511917 -0600 CST    deployed        mushop-0.1.0                    1.0         
    oci-broker              mushop-utilities        1               2020-01-31 20:46:30.565257 -0600 CST    deployed        oci-service-broker-1.3.3                   
    mushop-provision        mushop                  1               2020-01-31 21:01:54.086599 -0600 CST    deployed        mushop-provision-0.1.0          0.1.0      
    mushop-utils            mushop-utilities        1               2020-01-31 20:32:05.864769 -0600 CST    deployed        mushop-setup-0.0.1              1.0  
    ```

- Remove the application from Kubernetes where `--name mushop` was used during install:

    ```shell--helm2
    helm delete --purge mushop
    ```

    ```shell--helm3
    helm delete mushop -n mushop
    ```

- If used OCI Service broker, remove the `provision` dependency installation, including ATP Bindings (Wallet, password) and instances:

    ```shell--helm2
    helm delete --purge mushop-provision
    ```

    ```shell--helm3
    helm delete mushop-provision -n mushop
    ```

    {{% alert icon="info" %}}
    After delete, `kubectl get serviceinstances -A` will show resources that are deprovisioning
    {{% /alert %}}

- If used OCI Service broker, remove the `oci-broker` installation:

    ```shell--helm2
    helm delete --purge oci-broker
    ```

    ```shell--helm3
    helm delete oci-broker -n mushop-utilities
    ```

- Uninstall Istio service mesh _(if applicable)_:

    ```shell
    istioctl manifest generate --set profile=demo | kubectl delete -f -
    ```

- Remove the `setup` cluster dependency installation:

    ```shell--helm2
    helm delete --purge mushop-utils
    ```

    ```shell--helm3
    helm delete mushop-utils -n mushop-utilities
    ```
