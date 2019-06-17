# MuShop

The Microservices Demo using Oracle Cloud Infrastructure (OCI) - Rebranded to MuShop

## Services

| Service                           | Language  | Cloud Services        | Description                                                                                                                       | Build Status  |
| --------------------------------- | --------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| [api](./src/api)                  | Node.js   |                       | Orchestrating services for consumption by Storefront                                                                              |   |
| [carts](./src/carts)              | Java      | Autonomous DB (ATP)   | Provides shopping carts for users                                                                                                 |   |
| [catalogue](./src/catalogue)      | Go        | Autonomous DB (ATP)   | Provides catalogue/product information stored on Oracle Autonomous Database. Uses GOracle.v2 with GoKit and OCI Service Broker    | [![wercker status](https://app.wercker.com/status/f59f625d8e8d9c33c00378517e1b26bb/s/ "wercker status")](https://app.wercker.com/project/byKey/f59f625d8e8d9c33c00378517e1b26bb)|
| [orders](./src/orders)            | Java      | Autonomous DB (ATP)   | Orders service using Springboot                                                                                                   |   |
| [payments](./src/payments)        | Go        |                       | TBD                                                                                                                               |   |
| [queue](./src/queue)              | Java      | Oracle Streaming      | Consumes shipping messages from OCI Streams                                                                                       |   |
| [shipping](./src/shipping)        | Java      | Oracle Streaming      | Receives  messages when an item is shipped and forward to Oracle Streams                                                                                   |   |
| [storefront](./src/storefront)    | Node.js   |                       | Responsive eCommerce storefront single page application built on microservices architecture.                                      |   |
| [user](./src/user)                | Go        |                       | TBD                                                                                                                               |   |
| [edge-router](./src/edge-router)  | traefik   | Development only      | Optional Edge routing container for MuShop backend/frontend services. Used for running development environments                   |   |


## Instructions to connect to OSS

Detailed instructions are found in this [document](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)


* Create user in IAM for the person or system who will be calling the API
    * Add desired permissions
* Generate API signing key. More detailed instructions can be found [OCI Documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How)
    * Generate a key with no passphrase to make it simple.
* Get fingerprint of the public key
* Upload the public key to OCI’s console
* Get the following:
    * Tenancy’s OCID 
    * User’s OCID
    * Compartment’s OCID
    * Region 
* Create the scripts below.

## Environment Setup
In order to connect to external services such as Autonomous Transaction Processing (ATP) or Oracle Streaming Services (OSS), you will need to create the following secrets. These can be in a script if you prefer.
Note that passwords have been masked and you need to substitute with your own passwords.

Secret for ATP access:
```text
kubectl create secret generic atp-secret \
--from-literal=catalogue_oadb_user="catalogue_user" \
--from-literal=catalogue_oadb_pw="xxxxxx" \
--from-literal=catalogue_oadb_service="mcatalogue_tp" \
--from-literal=carts_oadb_user="carts_user" \
--from-literal=carts_oadb_pw="xxxxxx" \
--from-literal=carts_oadb_service="mcarts_tp" \
--from-literal=orders_oadb_user="orders_user" \
--from-literal=orders_oadb_pw="xxxxxx" \
--from-literal=orders_oadb_service="morders_tp"
```

Secret for OSS access:
```text
kubectl create secret generic streams-secret \
--from-literal=oci_compartment_id="<your compartment id>" \
--from-literal=oci_tenant_id="<your tenant id>" \
--from-literal=oci_user_id="<your user id>" \
--from-literal=oci_fingerprint="<your API key fingetprint>" \
--from-literal=oci_region="<your region>" \
--from-file=oci_api_key=\<your home folder>/.oci/oci_api_key.pem
```


