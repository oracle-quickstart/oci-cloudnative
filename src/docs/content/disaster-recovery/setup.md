---
title: "Setup"
date: 2021-08-10T13:29:23-06:00
draft: false
weight: 3
tags:
  - Autonomous Data Guard
  - Autonomous Transaction Processing
  - Disaster Recovery
---

## Introduction

In this section we detail the steps required to perform a DR solution between
`us-phoenix-1` and `us-ashburn-1` regions. These regions are used as an example,
you can choose the regions of your choice.

### Set Environment Variables

    export COMPARTMENT_ID=<COMPARTMENT_ID>
    export DB_NAME=demoadb
    export DB_DISPLAY_NAME=demoadb
    export DB_PASSWORD=<DB_PASSWORD>
    export WALLET_PW=<DB_WALLET_PASSWORD>
    export DB_SERVICE_NAME=${DB_NAME}_tp
    export WALLET_ZIP=/tmp/Wallet_${DB_NAME}.zip
    export PRIMARY_REGION=us-phoenix-1
    export FAILOVER_REGION=us-ashburn-1

Do refer the autonomous database password criteria's [here](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/manage-users-create.html#GUID-72DFAF2A-C4C3-4FAC-A75B-846CC6EDBA3F)

### Setup ADB (Autonomous Database)

- Create the Source ADB (Autonomous Database)

```shell
    oci db autonomous-database create --compartment-id ${COMPARTMENT_ID} \
    --db-name ${DB_NAME} --admin-password ${DB_PASSWORD} --db-version 19c \
    --cpu-core-count 1 --data-storage-size-in-tbs 1 \
    --display-name ${DB_DISPLAY_NAME} --region ${PRIMARY_REGION}
```

- Fetch the Source ADB (Autonomous Database) OCID

```bash
    DB_ID=$(oci db autonomous-database list -c ${COMPARTMENT_ID} \
    --region ${PRIMARY_REGION} --display-name $DB_NAME \
    --query "data[?\"db-name\"=='${DB_NAME}'].id | [0]" --raw-output)
```

- Create the DR ADB (Autonomous Database)

```bash
    oci db autonomous-database create-adb-cross-region-data-guard-details \
    --compartment-id ${COMPARTMENT_ID} --db-name ${DB_NAME} --source-id ${DB_ID} \
    --cpu-core-count 1 --data-storage-size-in-tbs 1 \
    --region ${FAILOVER_REGION} --db-version 19c
```

- Download and extract autonomous database wallet from source ADB

```bash
    oci db autonomous-database generate-wallet --autonomous-database-id ${DB_ID}\
    --password ${WALLET_PW} --file ${WALLET_ZIP} --region $PRIMARY_REGION
```

```bash
    unzip ${WALLET_ZIP} -d /tmp/wallet_source
```

{{% alert style="information" icon="information" %}}
Keep this wallet handy as we will need to add it as OKE secret later on.

The database wallet on standby(DR) will not be available for download until the failover.
The wallet has to be separately downloaded for primary and remote region's as tnsnames.ora DNS entries are different.
{{% /alert %}}

## Create OKE (Oracle Cloud Infrastructure Container Engine for Kubernetes) clusters

Follow the instructions provided [here](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html#DefineClusterDetails) on both primary and DR sites.

### Setup Mushop on Source (`us-phoenix-1`)

- Go to the chart folder

    ```bash
    cd oci-cloudnative/deploy/complete/helm-chart
    ```

- Install Setup Charts

    ```shell--helm3
    helm upgrade --install mushop-utils setup --dependency-update --namespace mushop-utilities --create-namespace
    ```

- Add the following secrets

    ```bash
    kubectl create secret generic oci-credentials \
        --namespace mushop \
        --from-literal=tenancy=<TENANCY_OCID> \
        --from-literal=user=<USER_OCID> \
        --from-literal=region=<USER_OCI_REGION> \
        --from-literal=fingerprint=<USER_PUBLIC_API_KEY_FINGERPRINT> \
        --from-literal=passphrase=<PASSPHRASE_STRING> \
        --from-file=privatekey=<PATH_OF_USER_PRIVATE_API_KEY>
    ```

    ```bash
    kubectl create secret generic oadb-admin \
        --namespace mushop \
        --from-literal=oadb_admin_pw=${DB_PASSWORD}
    ```

    ```bash
    kubectl create secret generic oadb-wallet \
        --namespace mushop --from-file=/tmp/wallet_source
    ```

    ```bash
    kubectl create secret generic oadb-connection \
        --namespace mushop \
        --from-literal=oadb_wallet_pw=${WALLET_PW} \
        --from-literal=oadb_service=${DB_SERVICE_NAME}
    ```

- Edit/Add the following secrets to values-prod.yaml as shown below

    ```bash
    cat mushop/values-prod.yaml
    ```

Sample Output:

```yaml
global:
ociAuthSecret: oci-credentials        # OCI authentication credentials secret name
ossStreamSecret:                      # Name of Stream Connection secret
oadbAdminSecret: oadb-admin           # Name of DB Admin secret created earlier
oadbWalletSecret: oadb-wallet         # Name of wallet secret created earlier
oadbConnectionSecret: oadb-connection # Name of connection secret created earlier
```

- Install MuShop

    ```shell--helm3
    helm upgrade --install -f ./mushop/values-prod.yaml \
    mymushop mushop -n mushop \
    --create-namespace
    ```

- Setup the ingress
A TLS secret is used for SSL termination on the ingress controller. To generate the secret for this example, a self-signed certificate is used. While this is okay for testing, for production, use a certificate signed by a Certificate Authority.

    ```bash
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 -keyout tls.key \
    -out tls.crt -subj "/CN=nginxsvc/O=nginxsvc"
    ```

    ```bash
    kubectl create secret tls tls-secret --key tls.key --cert tls.crt -n mushop
    ```

    ```bash
    cat << EOF | kubectl -n mushop apply -f -
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
        name: mushop
    spec:
        ingressClassName: nginx
        tls:
        - secretName: tls-secret
        rules:
        - http:
            paths:
            - path: /
                pathType: Prefix
                backend:
                service:
                    name: edge
                    port:
                    number: 80
    EOF
    ```

- Access the Source MuShop application using the ingress IP

    ```bash
    kubectl get svc mushop-utils-ingress-nginx-controller \
    --namespace mushop-utilities
    ```

- Verify the application at Source

   Access `https://<primary-site-ingress-ip-address>` and ensure that you would
   see the all the MuShop catalogue products listed without errors.

### Perform Autonomous Transaction Processing (ATP) Failover

Go to OCI console and perform a failover.

```text
OCI-Console -> Oracle Database -> Autonomous Transaction Processing (Standby db: `us-ashburn-1`) -> Switchover
```

{{% alert style="information" icon="information" %}}
Wait until the switchover completes fully and there are no 'role change in progress'
status on either side (Primary and Standby).
{{% /alert %}}

### MuShop Setup (Disaster Recovery (DR) site `us-ashburn-1`)

Change your OKE cluster to point to DR. If you don't have a DR OKE cluster setup yet then refer to the [Create OKE clusters](#create-oke-oracle-cloud-infrastructure-container-engine-for-kubernetes-clusters)
section and create a OKE cluster at the DR region.

- Download and extract the DR ADB wallet

    ```text
    OCI-Console -> Oracle Database -> Autonomous Transaction Processing (Standby db: `us-ashburn-1`) -> DB Connection -> Download wallet
    ```

Extract the wallet

```bash
unzip <wallet_zip_file> -d /tmp/wallet_remote
```

- Create the secrets, set the region as `us-ashburn-1` in this case

    ```bash
    kubectl create secret generic oci-credentials \
        --namespace mushop \
        --from-literal=tenancy=<TENANCY_OCID> \
        --from-literal=user=<USER_OCID> \
        --from-literal=region=<USER_OCI_REGION> \
        --from-literal=fingerprint=<USER_PUBLIC_API_KEY_FINGERPRINT> \
        --from-literal=passphrase=<PASSPHRASE_STRING> \
        --from-file=privatekey=<PATH_OF_USER_PRIVATE_API_KEY>
    ```

    ```bash
    kubectl create secret generic oadb-wallet \
        --namespace mushop   --from-file=/tmp/wallet_remote
    ```

    ```bash
    kubectl create secret generic oadb-admin \
        --namespace mushop \
        --from-literal=oadb_admin_pw=${DB_PASSWORD}
    ```

    ```bash
    kubectl create secret generic oadb-connection \
        --namespace mushop \
        --from-literal=oadb_wallet_pw=${WALLET_PW} \
        --from-literal=oadb_service=${DB_SERVICE_NAME}
    ```

- Edit/Add the following secrets to values-prod.yaml as shown below

    ```bash
    cat mushop/values-prod.yaml
    ```

Sample Output:

```yaml
global:
ociAuthSecret: oci-credentials        # OCI authentication credentials secret name
ossStreamSecret:                      # Name of Stream Connection secret
oadbAdminSecret: oadb-admin           # Name of DB Admin secret created earlier
oadbWalletSecret: oadb-wallet         # Name of wallet secret created earlier
oadbConnectionSecret: oadb-connection # Name of connection secret created earlier
```

- Install MuShop

    ```shell--helm3
    helm upgrade --install -f ./mushop/values-prod.yaml \
    mymushop mushop -n mushop
    ```

- Set up the ingress (On DR `us-ashburn-1`)

    ```bash
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 -keyout tls.key \
    -out tls.crt -subj "/CN=nginxsvc/O=nginxsvc"
    ```

    ```bash
    kubectl create secret tls \
    tls-secret --key tls.key --cert tls.crt -n mushop
    ```

    ```bash
    cat << EOF | kubectl -n mushop apply -f -
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
        name: mushop
    spec:
        ingressClassName: nginx
        tls:
        - secretName: tls-secret
        rules:
        - http:
            paths:
            - path: /
                pathType: Prefix
                backend:
                service:
                    name: edge
                    port:
                    number: 80
    EOF
    ```

### Verify the application at DR

    kubectl get svc mushop-utils-ingress-nginx-controller -n mushop-utilities

Access `https://<dr-site-ingress-ip-address>` and ensure that you would see the
all the MuShop catalogue products listed without errors.

### DR Testing

Notice that the source (`us-phoenix-1`) site has lost access to all the
products within Mushop and the DR site has access to all the products as we switched over.

You can then ADB fail back to the primary site (`us-phoenix-1`) in this case and
observe the opposite behavior.

### WAF and DNS traffic steering

Further, we can add WAF and DNS traffic steering policy to automatically switch
the DNS from Source site to Destination site. For this we make use of creating
a http healthcheck monitor on `https://<primary-site-ingress-ip-address>/api/catalogue`.
When we failover the ATP (Autonomous Database) manually or when there is a disaster at
Primary site, this check would then fail and automatically change the DNS to point to DR
Ingress IP. The procedure to setup WAF and DNS are not included as part of this lab.
