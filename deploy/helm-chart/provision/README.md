Prerequisites:
- service catalog installed (run the setup chart to install it)

1. Set the namespace as an environment variable:

    ```text
    export MUSHOP_NAMESPACE=mushop
    ```

1. Install the OCI service broker:

    ```text
    helm install https://github.com/oracle/oci-service-broker/releases/download/v1.3.1/oci-service-broker-1.3.1.tgz  --name oci-service-broker \
      --namespace $MUSHOP_NAMESPACE \
      --set ociCredentials.secretName=oci-service-broker \
      --set storage.etcd.useEmbedded=true \
      --set tls.enabled=false
    ```

    >Note: instead of doing helm install like this, we could copy the .tgz file and use one helm install command to install everything.

    >Another note: The OCI service broker pod will be failing due to a missing secret - that secret is deployed using the provision chart below. If we did the fix above (copy tgz manually and install everyhing using helm), then this wouldn't be happening.

    >Etcd node: The above command will deploy the OCI Service Broker using an embedded etcd instance. It is not recommended to deploy the OCI Service Broker using an embedded etcd instance and tls disabled in production environments, instead a separate etcd cluster should be setup and used by the OCI Sevice Broker.

1. Complete secret information as described in [./secrets](./secrets/README.md)

1. Create a `myvalues.yaml` file with the following information:

    ```yaml
    global:
      osb:
        compartmentId: ocid1.compartment.oc1..aaaaaaaaxxxx...

    secrets:
      serviceBroker:
        tenantId: ocid1.tenancy.oc1..aaaaaaaaxxxx...
        userId: ocid1.user.oc1..aaaaaaaaxxxx...
        region: us-phoenix-1
        # API Key
        keyFile: secrets/osb_key.pem
        fingerprint: 43:62:xx...
        passphrase: xxxxxxxxx
    ```

1. Install the provision Helm chart:

    ```text
    helm install provision \
      --name mushop-provision \
      --namespace $MUSHOP_NAMESPACE \
      --values myvalues.yaml
    ```

Use `kubectl get serviceinstances -A` and `kubectl get servicebindings -A`
to ensure service instances  are created before you continue installing
the `mushop` deployment Helm chart.