# Provisioning with Open Service Broker

The `provision` chart is an application of the open source
[OCI Service Broker](https://github.com/oracle/oci-service-broker)
for _provisioning_ Oracle Cloud Infrastructure services. This implementation
utilizes [Open Service Broker](https://github.com/openservicebrokerapi/servicebroker/blob/v2.14/spec.md)
in Oracle Container Engine for Kubernetes or in other Kubernetes clusters.

## Prerequisites

The service catalog must be installed. This is installed by default with the [`setup`](../README.md#setup)
umbrella chart included here. Either complete the setup, or follow these instructions to install manually:

1. Add the helm repository:

    ```shell
    helm repo add svc-cat https://kubernetes-sigs.github.io/service-catalog
    ```

1. Create a namespace:

    ```shell
    kubectl create ns service-catalog
    ```

1. Install the Kubernetes Service Catalog helm chart:

    ```shell
    helm install catalog svc-cat/catalog --namespace service-catalog
    ```

    Or using Helm V2

    ```shell
    helm install svc-cat/catalog --name catalog --namespace service-catalog
    ```

## Setup

1. Create a secret `oci-credentials` with Oracle Cloud Infrastructure [API credentials](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionssetupapikey.htm):

    ```shell
    kubectl create secret generic oci-credentials \
      --namespace mushop \
      --from-literal=tenancy=<TENANCY_OCID> \
      --from-literal=user=<USER_OCID> \
      --from-literal=region=<USER_OCI_REGION> \
      --from-literal=fingerprint=<USER_PUBLIC_API_KEY_FINGERPRINT> \
      --from-literal=passphrase=<PASSPHRASE_STRING> \
      --from-file=privatekey=<PATH_OF_USER_PRIVATE_API_KEY>
    ```

    > **NOTE:** The passphrase entry is **required**. If you do not have passphrase for your key, just leave empty

1. Install the OCI service broker referencing the credentials above:

    ```text
    helm install oci-service-broker https://github.com/oracle/oci-service-broker/releases/download/v1.6.0/oci-service-broker-1.6.0.tgz \
      --namespace mushop \
      --set ociCredentials.secretName=oci-credentials \
      --set storage.etcd.useEmbedded=true \
      --set tls.enabled=false
    ```

    >Note: instead of doing helm install like this, we could copy the .tgz file and use one helm install command to install everything.

    >Another note: The OCI service broker pod will be failing due to a missing secret - that secret is deployed using the provision chart below. If we did the fix above (copy tgz manually and install everything using helm), then this wouldn't be happening.

    >Etcd node: The above command will deploy the OCI Service Broker using an embedded etcd instance. It is not recommended to deploy the OCI Service Broker using an embedded etcd instance and tls disabled in production environments, instead a separate etcd cluster should be setup and used by the OCI Service Broker.

1. Create a `myvalues.yaml` file with the following information:

    ```yaml
    global:
      osb:
        compartmentId: ocid1.compartment.oc1..aaaaaaaaxxxx...
    ```

1. Install the provision Helm chart:

    ```text
    helm install mushop-provision provision \
      --namespace mushop \
      --values myvalues.yaml
    ```

    Or with Helm V2

    ```text
    helm install provision \
      --name mushop-provision \
      --namespace mushop \
      --values myvalues.yaml
    ```

Use `kubectl get serviceinstances -A` and `kubectl get servicebindings -A`
to ensure service instances  are created before you continue installing
the `mushop` deployment Helm chart.
