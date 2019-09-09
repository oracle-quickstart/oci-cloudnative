Before installing the chart, copy the following files to this folder:

```
oci_streams_api_key.pem
oci_service_broker_api_key.pem
```

The `oci_streams_api_key.pem` is the key to access an OCI account used by the streams service.

The `oci_service_broker_api_key.pem` is the key to access an OCI account used by the service broker.

The API key files and corresponding secrets are separated in case we want to use streams service from account A and service broker from account B. However, the files and secret values could also be identical and point to the same OCI account.