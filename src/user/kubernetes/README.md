# MuShop User Service in K8s

## Configuration

Several steps are required in order to properly configure the `user` service for use in Kubernetes. Follow these instructions to prepare a Kubernetes cluster.

1. Provision an instance of Oracle Autonomous Transaction Processing database.
    > ⚠️**Note** the `ADMIN` password used and keep this available.

1. Download the **DB Connection** Credential Wallet and extract to a local working directory.
    > ⚠️ **Note** the **Wallet** password used for download and keep this available.

1. Create a Kubernetes secret containing the **Wallet** contents.

    ```text
    kubectl create secret generic user-oadb-wallet \
      --from-file=Wallet_Creds
    ```

    > The Wallet is shown here with `Wallet_*.zip` extracted to a directory named `Wallet_Creds`.

1. Create a Kubernetes secret with the database `ADMIN` password specified during provisioning.

    ```text
    kubectl create secret generic user-oadb-admin \
      --from-literal=oadb_admin_pw='xxxxxx'
    ```

    > 🔒 This is used to initialize database schema and create service credentials. It may be disposed after intial configuration.

1. Create a Kubernetes secret with the ATP **schema user** credentials and **Connection String** information.

    ```text
    kubectl create secret generic user-oadb-connection \
      --from-literal=oadb_wallet_pw='xxxxxx' \
      --from-literal=oadb_service={generateddbname}_tp \
      --from-literal=oadb_user='xxxxxx' \
      --from-literal=oadb_pw='xxxxxx'
    ```

    > ⚠️ Credentials `oadb_user` and `oadb_pw` are defined here, which are used by services connecting to ATP. The `oadb_service` string is the desired [TNS Name][tns], and follows the naming pattern: `{db.name}_tp`.

## Initialization

1. If not done already, build the docker image from the `src/user` service root.

    ```text
    docker build -t mushop/user .
    ```

1. Create the user connection credentials and database schema.

    ```text
    kubectl create -f init-job.yaml
    ```

    > **NOTE:** this can be replaced by binding init operation when using Service Broker

1. Synchronize the table schema with [TypeOrm](https://typeorm.io) entity models

    ```text
    kubectl apply -f sync-job.yaml
    ```

    > ⚠️ This should be repeated any time the entity model definitions are changed

## Deploy

```text
kubectl apply -f users.yaml
```

## Resources

- [K8s Secrets][secrets]
- [TNS Names][tns]

[tns]: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbconnecting.htm#about
[secrets]: https://kubernetes.io/docs/concepts/configuration/secret/