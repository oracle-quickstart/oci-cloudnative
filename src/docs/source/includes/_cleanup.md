# Cleanup

The following list represents cleanup operations, which may vary
depending on the actions performed for setup and deployment of MuShop.

- List any `helm` releases that may have been installed:

    ```text
    helm list
    ```

    ```text
    NAME          REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
    mushop-setup  1               Tue Nov 12 06:12:45 2019        DEPLOYED        mushop-setup-0.0.1      1.0             mushop-setup
    mushop        1               Wed Nov 13 20:23:28 2019        DEPLOYED        mushop-0.1.0            1.0             mushop
    ```

- Remove the application from Kubernetes where `--name mushop` was used during install:

    ```shell
    helm delete --purge mushop
    ```

- Remove the `setup` cluster dependency installation:

    ```shell
    helm delete --purge mushop-setup
    ```
