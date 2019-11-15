# MuShop Provisioning Secrets

## API Key

Before installing the chart, create the following files inside this folder:

| Name | Type | Description | Required |
|---|---|---|---|
| `oci_service_broker_api_key.pem` | File | API Key corresponding to OCI account used by service broker | Y |

You may use a filename of your choosing, in which case simply specify the following `values.yaml` accordingly:

```yaml
secrets:
  serviceBroker:
    fingerprint: xx:xx:xx....
    tenantId: ocid1.tenancy.oc1..aaaaaaaaxxxx...
    userId: ocid1.user.oc1..aaaaaaaaxxxx...
    region: us-phoenix-1
    # API Key
    keyFile: secrets/osb_key.pem
    fingerprint: 43:62:xx...
    passphrase: xxxxxxxxx
```
