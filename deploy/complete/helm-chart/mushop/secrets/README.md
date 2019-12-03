# MuShop Secrets

## API Key

Before installing the chart, create the following files inside this folder:

| Name | Type | Description | Required |
|---|---|---|---|
| `oci_streams_api_key.pem` | File | API Key corresponding to OCI account used by the streams service | Y |
| `oci_service_broker_api_key.pem` | File | API Key corresponding to OCI account used by service broker | N |

> The API key files and corresponding secrets are separated in case we want to use streams service from account **A** and service broker from account **B**. However, the files and secret values could also be identical and point to the same OCI account.

You may use a filename of your choosing, in which case simply specify the following `values` accordingly:

```yaml
secrets:
  streams:
    fingerprint: xx:xx:xx....
    keyFile: secrets/stream_key.pem
    passphrase: xxxxxxxxx
    #...
  serviceBroker:
    fingerprint: xx:xx:xx....
    keyFile: secrets/osb_key.pem
    passphrase: xxxxxxxxx
    #...
```
