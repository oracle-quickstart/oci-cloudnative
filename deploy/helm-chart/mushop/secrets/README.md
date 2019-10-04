Before installing the chart, create the following files inside this folder:

```text
oci_streams_api_key.pem
oci_service_broker_api_key.pem
```

| Name | Type | Description | Required |
|---|---|---|---|
| `oci_streams_api_key.pem` | File | API Key corresponding to OCI account used by the streams service | Y |
| `oci_service_broker_api_key.pem` | File | API Key corresponding to OCI account used by service broker | Y |

> The API key files and corresponding secrets are separated in case we want to use streams service from account **A** and service broker from account **B**. However, the files and secret values could also be identical and point to the same OCI account.