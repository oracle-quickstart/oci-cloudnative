Prerequisites:
- service catalog installed (run the setup chart to install it)

1. Set the namespace:

```
export MUSHOP_NAMESPACE=mushop-dev
```

1. Install the OCI service broker:

```
helm install https://github.com/oracle/oci-service-broker/releases/download/v1.3.1/oci-service-broker-1.3.1.tgz  --name oci-service-broker \
  --namespace $MUSHOP_NAMESPACE \
  --set ociCredentials.secretName=oci-service-broker \
  --set storage.etcd.useEmbedded=true \
  --set tls.enabled=false
```

>Note: instead of doing helm install like this, we could copy the .tgz file and use one helm install command to install everything.

>Another note: The OCI service broker pod will be failing due to a missing secret - that secret is deployed using the provision chart below. If we did the fix above (copy tgz manually and install everyhing using helm), then this wouldn't be happening.

>Etcd node: The above command will deploy the OCI Service Broker using an embedded etcd instance. It is not recommended to deploy the OCI Service Broker using an embedded etcd instance and tls disabled in production environments, instead a separate etcd cluster should be setup and used by the OCI Sevice Broker.

1. Install the provision Helm chart:

```
helm install provision --name mushop-provision --namespace $MUSHOP_NAMESPACE --values provision/values.yaml
```

Use `kubectl get serviceinstances -A` to ensure service instances are created before you continue installing the Mushop Helm chart.