# Wallet Secrets

This service requires the use of an Oracle Database Wallet for connection information.
To prepare the chart to consume these secrets, simply extract the `Wallet_{name}.zip`
as a folder in this directory.

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
