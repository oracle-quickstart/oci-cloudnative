# Catalogue (Local Development - Kubernetes)

Local development instructions

## Requirements

These steps are necessary if you using a local kubernetes (e.g.: Docker Desktop K8s) or in a different cluster from the mushop app.

If you are using a cluster with already deployed the MuShop App, the steps are not necessary.

### 1) Helm Installed

Installs helm client and the optional svcat cli:

  ```brew update && brew install kubernetes-helm kubernetes-service-catalog-client```

Check if the version of the client and the server:

  ```helm version```

If the server have not initialized, use this command:

```helm init --history-max 200```

### 2) Service Catalog deployed to the cluster used for development

> You can check if the Service Catalog have been already deployed by checking if the pods are in the cluster: ```kubectl get pods -n service-catalog```

Add the Kubernetes Service Catalog helm repository:

```helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com```

Install the Kubernetes Service Catalog helm chart:

```helm install svc-cat/catalog --name catalog --namespace service-catalog```

### 3) Create a namespace for the development

> You can use the main mushop namespace. Here the instructions to create a separate one.
> You can check the namespaces on your context using this command: ```kubectl get namespaces --show-labels```

Create namespace:
```kubectl create namespace mushop-dev```

You can optionally label your namespace:

```kubectl label namespace mushop-dev name=mushop-development```

### 4) Service credentials as a Kubernetes secret for the OCI Service Broker

Create secret:

```shell
kubectl --namespace=mushop-dev create secret generic ocicredentials \
--from-literal=tenancy=<CUSTOMER_TENANCY_OCID> \
--from-literal=user=<USER_OCID> \
--from-literal=fingerprint=<USER_PUBLIC_API_KEY_FINGERPRINT> \
--from-literal=region=<USER_OCI_REGION> \
--from-literal=passphrase=<PASSPHRASE_STRING> \
--from-file=privatekey=<PATH_OF_USER_PRIVATE_API_KEY>
```

> Note: The passphrase entry is necessary, even if you do not have passphrase for your key, just leave empty

### 5) Install OCI Service Broker

```shell
helm install https://github.com/oracle/oci-service-broker/releases/download/v1.6.0/oci-service-broker-1.6.0.tgz  --name oci-service-broker \
  --namespace mushop-dev \
  --set ociCredentials.secretName=ocicredentials \
  --set storage.etcd.useEmbedded=true \
  --set tls.enabled=false
```

### 6) Deploy OCI Service Broker Service

> Note: Check if there's a service broker already running: ```kubectl get clusterservicebrokers```

```shell
cat <<EOF | kubectl create -f -
apiVersion: servicecatalog.k8s.io/v1beta1
kind: ClusterServiceBroker
metadata:
  name: oci-service-broker
spec:
  url: http://oci-service-broker.mushop-dev:8080
EOF
```

> Note: To check that the service broker is running and fetched catalog, run: ```kubectl get clusterservicebrokers -o 'custom-columns=BROKER:.metadata.name,STATUS:.status.conditions[0].reason'```

### 7) Database secrets

1. Create a Kubernetes secret with the database `ADMIN` password specified during provisioning.

    ```text
    kubectl --namespace=mushop-dev create secret generic catalogue-oadb-admin \
      --from-literal=oadb_admin_pw='{"password":"s123456789S@"}'
    ```

    > ⚠️ The password on this example is just a placeholder, please change to your own

1. Create a Kubernetes secret with the ATP **schema catalogue** credentials and **Connection String** information.

    ```text
    kubectl --namespace=mushop-dev create secret generic catalogue-oadb-connection \
      --from-literal=oadb_wallet_pw='{"walletPassword":"Welcome_123"}' \
      --from-literal=oadb_service={generateddbname}_tp \
      --from-literal=oadb_user='CATALOGUE_USER' \
      --from-literal=oadb_pw='default_Password1'
    ```

    > ⚠️ The passwords and schema user on this example are just placeholders, please change to your own
    > ⚠️ Credentials `oadb_user` and `oadb_pw` are defined here, which are used by services connecting to ATP. The `oadb_service` string is the desired [TNS Name][tns], and follows the naming pattern: `{db.name}_tp`.

### 8) Config Maps

1. Create a Kubernetes configMap with the sql script that will be used during the first run of the catalogue service.

```shell
kubectl --namespace=mushop-dev create configmap catalogue-sql --from-file=../dbdata/catalogue.sql
```

## Autonomous Database Provisioning

### 1) ATP Instance Provisioning

This step will provision an ATP instance.

Update the file `catalogue-oadb-instance.yaml` with your `compartmentId`. You can also optionally update the dbName and name fields and the db configuration if you want.

```shell
kubectl --namespace=mushop-dev create -f catalogue-oadb-instance.yaml
```

Check the status of the instance using the command:
```kubectl --namespace=mushop-dev get serviceinstances```

Wait for the status be `Ready` before go to the next step

### 2) ATP Binding

This step will create the wallet and store as a Kubernetes Secret.

```shell
kubectl --namespace=mushop-dev create -f catalogue-oadb-binding.yaml
```

## Catalogue Service Deployment

### 1) Deploy kubernetes service for catalogue service

```shell
kubectl --namespace=mushop-dev create -f catalogue-svc.yaml
```

### 2) Deploy kubernetes deployment for catalogue service

This step will extract the wallet, create the database schema user, create tables and populate the data on the first run, then will start the catalogue service.

```shell
kubectl --namespace=mushop-dev create -f catalogue-dep.yaml
```

## Local testing

```kubectl port-forward svc/catalogue 8000:80```

```curl localhost:8000/catalogue```
