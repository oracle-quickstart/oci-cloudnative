# MuShop Secrets

## API Key

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

## Wallet

In cases where a single Wallet is shared across services, its files may be added here
by extracting the `Wallet_{name}.zip` file as a folder in this directory.

> Example `Wallet`

```text
secrets/
├── README.md
└── Wallet_mushop
    ├── cwallet.sso
    ├── ewallet.p12
    ├── keystore.jks
    ├── ojdbc.properties
    ├── sqlnet.ora
    ├── tnsnames.ora
    └── truststore.jks
```

Then configure the global `values` accordingly:

```yaml
global:
  secrets:
    oadbAdminPassword: 'xxxxxx'
    oadbWallet: secrets/Wallet_dbname/
    oadbWalletPassword: 'xxxxxx'
    oadbService: dbname_tp
```
