# Cloud Deployment

## Prerequisites

In order connect the MuShop application with services in Oracle Cloud Infrastructure,
several configurations are necessary. These tenancy configurations will be used to
properly provision and/or connect cloud services: Create a file with the following
information to simplify lookups later:

```yaml
region:       # Region where resources will be provisioned. (ex: us-phoenix-1)
tenancy:      # Tenancy OCID value
user:         # API User OCID value
compartment:  # Compartment OCID value
key:          # Private API Key file path (ex: /Users/jdoe/.oci/oci_key.pem)
fingerprint:  # Public API Key fingerprint (ex: 43:65:2c...)
```

### Compartment

Depending on the tenancy and your level of access, you may want (or need) to
create a Compartment dedicated to this application and the resources allocated.

1. Open Console and navigate to Compartments

    > Governance and Admininstration » Identity » Compartments » `Create Compartment`

1. Specify metadata for the Compartment, and make note of the **OCID**

### API User

You will need a User with API Key access in your tenancy.
This can be your personal user account, or a virtual user specific to usage of
this application.

1. Open Console and navigate to Users

    > Governance and Admininstration » Identity » Users

1. Select _or create_ the user you wish to use

1. If necessary, follow these [instructions](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionssetupapikey.htm) to create an API key

1. Make note of the following items:
    - User **OCID**
    - API Key **Fingerprint**

### User Policies

If your configured User (with API Key) is **not** a member of the Administrators Group,
then a Group with specific Policies must be created, and the User added as a member.

1. Open Console and navigate to Groups

    > Governance and Admininstration » Identity » Groups » `Create Group`

1. Specify metadata for the Group, and make note of the **NAME**

1. Click the `Add User to Group` button and select your API User

1. Create a Policy with the folliwing statement:

    > Governance and Admininstration » Identity » Policies » `Create Policy`

    ```text
    Allow group <GroupName> to manage all-resources in compartment <CompartmentName>
    ```

<aside class="warning">
   This policy is intentionally broad for the sake of simplicity,
   and is <b>not</b> recommended in most real-world use cases.
   Refer to the <a href="https://docs.cloud.oracle.com/iaas/Content/Identity/Concepts/overview.htm#three">Documentation</a>
   for more on this topic.
</aside>

### Service Limits

Deploying the full application requires services from Oracle Cloud
Infrastructure. Use of these services will be subject to Service Limits in your
tenancy. Check minimum resource availability as follows:

> Check limits in the Console: Governance and Admininstration » Governance » Limits, Quotas, and Usage

| Service | Resource | Requirement |
| -- | -- | -- |
| Autonomous Transaction Processing Database | OCPU Count | `>=1` |
| Streaming | Partition Count | `>=1` |

<aside class="notice">
  This does not include requirements in cases where OKE is used.
</aside>

## Provisioning

Deploying the full application requires cloud backing services from Oracle Cloud Infrastructure.
Provisioning these services may be done manually of course, but can also be done _automatically_ 
through the use of [OCI Service Broker](https://github.com/oracle/oci-service-broker). You are
encouraged to explore each approach.

| [Manual](#manual-steps) | [Automated](#using-service-broker) |
|--|--|
| Provides steps for provisioning and connecting cloud services to the application | Uses OCI Service Broker to _provision_ **and** _connect_ the Autonomous Transaction Processing database |

In all cases, begin by adding tenancy credentials to manage and
connect services from within the cluster. Create a secret containing these
values:

```shell
kubectl create secret generic oci-credentials \
  --namespace mushop \
  --from-literal=tenancy=<TENANCY_OCID> \
  --from-literal=user=<USER_OCID> \
  --from-literal=region=<USER_OCI_REGION> \
  --from-literal=fingerprint=<PUBLIC_API_KEY_FINGERPRINT> \
  --from-literal=passphrase=<PRIVATE_API_KEY_PASSPHRASE> \
  --from-file=privatekey=<PATH_OF_PRIVATE_API_KEY>
```

> **NOTE:** The passphrase entry is **required**. If you do not have passphrase for your key, just leave empty.

### Manual Steps

Follow the steps outlined below to provision and configure the cluster with cloud service connection details

1. Provision an Autonomous Transaction Processing (ATP) database. The default options will work well, as will an **Always Free** shape if available. Once **RUNNING** download the DB Connection Wallet and configure secrets as follows:
    - Create `oadb-admin` secret containing the database administrator password. Used once for schema initializations.

        ```shell
        kubectl create secret generic oadb-admin \
          --namespace mushop \
          --from-literal=oadb_admin_pw='<DB_ADMIN_PASSWORD>'
        ```
    - Create `oadb-wallet` secret with the Wallet _contents_ using the downloaded `Wallet_*.zip`. The extracted `Wallet_*` directory is specified as the secret file path. Each file will become a key name in the secret data.

        ```shell
        kubectl create secret generic oadb-wallet \
          --namespace mushop \
          --from-file=<PATH_TO_EXTRACTED_WALLET_FOLDER>
        ```
    - Create `oadb-connection` secret with the Wallet **password** and the service **TNS name** to use for connections.

        ```shell
        kubectl create secret generic oadb-connection \
          --namespace mushop \
          --from-literal=oadb_wallet_pw='<DB_WALLET_PASSWORD>' \
          --from-literal=oadb_service='<DB_TNS_NAME>'
        ```

        > Each database has 5 unique TNS Names displayed when the Wallet is downloaded. For a database named `mushopdb` an example would be `mushopdb_TP`.

1. **Optional**: Instead of creating a shared database for the entire application, you may establish full separation of services by provisioning _individual_ ATP instances for each service that requires a database. To do so, repeat the previous steps for each database,and give each secret a unique name, for example: `carts-oadb-admin`, `carts-oadb-connection`, `carts-oadb-wallet`.
    - `carts`
    - `catalogue`
    - `orders`
    - `user`

1. Provision a Streaming instance from the Oracle Cloud Infrastructure [Console](https://console.us-phoenix-1.oraclecloud.com/storage/streaming), and make note of the created Stream `OCID` value. Then create an `oss-connection` secret containing the Stream connection details.

    ```shell
    kubectl create secret generic oss-connection \
      --namespace mushop \
      --from-literal=streamId='<STREAM_OCID>' \
      --from-literal=messageEndpoint='<MESSAGE_ENDPOINT_URL>'
    ```

1. **Optional**: Provision a **Public** Object Storage Bucket, and create a Pre-Authenticated Request for the bucket. With the information, create a secret called `oos-bucket` as follows:

    ```shell
    kubectl create secret generic oos-bucket \
      --namespace mushop \
      --from-literal=region=<BUCKET_REGION> \
      --from-literal=name=<BUCKET_NAME> \
      --from-literal=namespace=<OBJECT_STORAGE_NAMESPACE> \
      --from-literal=parUrl=<PRE_AUTHENTICATED_REQUEST_URL>
    ```

    > **Object Storage Namespace** may be found with the CLI `oci os ns get` or from the [tenancy information page](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)

1. Verify the secrets are created and available in the `mushop` namespace:

    ```shell
    kubectl get secret --namespace mushop
    ```

    ```text
    NAME              TYPE      DATA   AGE
    oadb-admin        Opaque    1      3m
    oadb-connection   Opaque    2      3m
    oadb-wallet       Opaque    7      3m
    oci-credentials   Opaque    6      3m
    oos-bucket        Opaque    4      3m
    oss-connection    Opaque    2      3m
    ```

### Using Service Broker

As an alternative to manually provisioning, the included [`provision`](https://github.com/oracle-quickstart/oci-cloudnative/tree/master/deploy/complete/helm-chart/provision)
chart is an application of the open-source [OCI Service Broker](https://github.com/oracle/oci-service-broker)
for _provisioning_ Oracle Cloud Infrastructure services. This implementation utilizes [Open Service Broker](https://github.com/openservicebrokerapi/servicebroker/blob/v2.14/spec.md) in Oracle Container Engine for Kubernetes or in other Kubernetes clusters.

```shell--linux-macos
cd deploy/complete/helm-chart
```

```shell--win
dir deploy/complete/helm-chart
```

1. The Service Broker for Kubernetes requires access credentials to provision and
manage services from within the cluster. Create a secret containing these
values as described [above](#provisioning). Alternatively, copy the `oci-credentials`
secret to the `mushop-utilities` namespace:

    ```shell
    kubectl get secret oci-credentials \
      --namespace=mushop \
      --export \
      -o yaml | kubectl apply \
      --namespace=mushop-utilities -f -
    ```

1. Deploy the OCI service broker on your cluster. This is done with the [Oracle OCI Service Broker](https://github.com/oracle/oci-service-broker) helm chart:

    ```shell--helm2
    helm install https://github.com/oracle/oci-service-broker/releases/download/v1.3.3/oci-service-broker-1.3.3.tgz \
      --namespace mushop-utilities \
      --name oci-broker \
      --set ociCredentials.secretName=oci-credentials \
      --set storage.etcd.useEmbedded=true \
      --set tls.enabled=false
    ```

    ```shell--helm3
    helm install oci-broker https://github.com/oracle/oci-service-broker/releases/download/v1.3.3/oci-service-broker-1.3.3.tgz \
      --namespace mushop-utilities \
      --set ociCredentials.secretName=oci-credentials \
      --set storage.etcd.useEmbedded=true \
      --set tls.enabled=false
    ```

    > The above command will deploy the OCI Service Broker using an embedded etcd instance. It is not recommended to deploy the OCI Service Broker using an embedded etcd instance and tls disabled in production environments, instead a separate etcd cluster should be setup and used by the OCI Service Broker.

  <aside class="warning">
    For the mushop <code>helm</code> deployment, the OCI Service Broker <b>MUST</b> be installed
    on the same namespace used by the <code>setup</code> chart. For convenience, the documentation
    commands defaults both the <code>setup</code> and OCI Service Broker charts to use
    the <code>mushop-utilities</code> namespace.
  </aside>
  
1. Next utilize the OCI Service Broker implementation to provision services by installing the included `provision` chart:

    ```shell--helm2
    helm install provision \
      --namespace mushop \
      --name mushop-provision \
      --set global.osb.compartmentId=<COMPARTMENT_ID> \
      --set global.osb.objectstoragenamespace=<OBJECT_STORAGE_NAMESPACE>
    ```

    ```shell--helm3
    helm install mushop-provision provision \
      --namespace mushop \
      --set global.osb.compartmentId=<COMPARTMENT_ID> \
      --set global.osb.objectstoragenamespace=<OBJECT_STORAGE_NAMESPACE>
    ```

    > **Object Storage Namespace** may be found with the CLI `oci os ns get` or from the [tenancy information page](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)

1. It will take a few minutes for the services database to provision, and the respective bindings to become available. Verify `serviceinstances` and `servicebindings` are **READY**:

    ```text
    kubectl get serviceinstances -A
    ```

    ```text
    NAME                   CLASS                                      PLAN       STATUS   AGE
    mushop-atp             ClusterServiceClass/atp-service            standard   Ready    1d
    mushop-objectstorage   ClusterServiceClass/object-store-service   standard   Ready    1d
    mushop-oss             ClusterServiceClass/oss-service            standard   Ready    1d
    ```

    ```text
    kubectl get servicebindings -A
    ```

    ```text
    NAME                         SERVICE-INSTANCE       SECRET-NAME                  STATUS   AGE
    mushop-bucket-par-binding    mushop-objectstorage   mushop-bucket-par-binding    Ready    1d
    mushop-oadb-wallet-binding   mushop-atp             mushop-oadb-wallet-binding   Ready    1d
    mushop-oss-binding           mushop-oss             mushop-oss-binding           Ready    1d
    ```

## API Gateway, OCI Functions and Email Delivery

<aside class="notice">
  Note that this is <b>OPTIONAL</b>. If you don't want to configure Email Delivery and deploy a function with API Gateway, skip to the
  <a href="#deployment">Deployment</a> section.
</aside>

### Configure Email Delivery

If you are planning to use the API gateway and Oracle Functions, to send emails using OCI Email Delivery you need to configure an approved sender first.

1. From the OCI console, click **Email Delivery** -> **Email Approved Sender**
1. Click the **Create Approved Sender**
1. Enter the email address, for example: `mushop@example.com`
1. Click **Create Approved Sender**

>Note: if you have your own domain, you can enter a different address (e.g.`mushop@[yourdomain.com]`) and also configure SPF record for the sender. This involves adding a DNS record to your domain. You can follow [these](https://docs.cloud.oracle.com/iaas/Content/Email/Tasks/configurespf.htm) instructions to set up SPF.

Next, you need to generate the SMTP credentials that will allow you to log in to the SMTP server and send the email. Follow the [Generate SMTP Credentails for a User](https://docs.cloud.oracle.com/iaas/Content/Email/Tasks/generatesmtpcredentials.htm) to get the SMTP host, port, username and password.

The SMTP credentails (host, port, username and password) and the approved sender email address (e.g. `mushop@example.com`) will be provided to the function as configuration values later, so make sure you save these values somewhere.

### Configure function application

Each function needs to live inside of an application. You can create a new application either through the console, API or the Fn CLI. An application has a name (e.g. `mushop-app`) and the VCN and a subnet in which to run the functions. The one guideline here is to pick the subnets that are in the same region as the Docker registry you specified in your context YAML earlier - check these [docs](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionscreatingapps.htm) for more information.

The first step you need to do is to ensure your tenancy is configured for function development. You can follow the [Configuring Your Tenancy for Function Development](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionsconfiguringtenancies.htm) documentation.

As a next step you will need to install the [Fn CLI](https://github.com/fnproject/cli). If on a Mac and you're using [Brew](https://brew.sh), you can run:

```shell
brew install fn
```

Finally, you will need configure the Fn CLI - you can follow [these instructions](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionscreatefncontext.htm) that will guide you through creating a context file and configuring it with an image registry.

To create an application using Fn CLI, run:

```shell
 fn create app [APP_NAME] --annotation oracle.com/oci/subnetIds='["ocid1.subnet.oc1.iad...."]'
```

>Note: make sure you replace `APP_NAME` and the `ocid1.subnet` with actual values

### Deploy and configure the function

To deploy a function to an app, you can run the following command within the function folder (`/src/functions/newsletter-subscription`):

```shell
fn deploy --app [APP_NAME]
```
>Note: use `fn -v deploy --app [APP_NAME]` to get verbose output in case you're running into issues.

In the remainder of the document, we will use `mushop-app` for the application name.

You need to provide additional configuration (SMTP credentails) for the function to work properly and be able to send emails.

Once you've successfully deployed the function, you can use the Fn CLI to add configuration values (note that you can also do the same through the Console UI).

Run the following commands to configure SMTP settings and the approved sender (replace the values):

```shell
fn config function mushop-app newsletter-subscription SMTP_USER <smtp_username>
fn config function mushop-app newsletter-subscription SMTP_PASSWORD <smtp_password>
fn config function mushop-app newsletter-subscription SMTP_HOST <smtp_host>
fn config function mushop-app newsletter-subscription SMTP_PORT <smtp_port>
fn config function mushop-app newsletter-subscription APPROVED_SENDER_EMAIL <approved_sender_email>
```

### Creating an API gateway

You will be using an [API Gateway](https://docs.cloud.oracle.com/iaas/Content/APIGateway/Concepts/apigatewayoverview.htm) to access the functions. To prepare your tenancy for using the gateway, check the [Preparing for API Gateway](https://docs.cloud.oracle.com/iaas/Content/APIGateway/Concepts/apigatewayprerequisites.htm) documentation.

The quickest way to create a gateway is through the OCI console:

1. Click **Developer Services** -> **API Gateway** from the sidebar on the left
1. Click the **Create Gateway** button
1. Enter the following values (you can use a different name if you'd like):
    - Name: **mushop-gateway**
    - Type: **Public**
    - Virtual Cloud Network: *Pick one from the dropdown*
    - Subnet: *Pick the subnet from the dropdown*
1. Click **Create**
1. When gateway is created, click the **Deployments** link from the sidebar on the left
1. Under the **Deployments**, click the **Create Deployment** button
1. Make sure **From Scratch** option is selected at the top and enter the following values (you can leave the other values as they are - i.e. no need to enable CORS, Authentication or Rate Limiting):
    - Name: **newsletter-subscription**
    - Path prefix: **/newsletter**
    - Compartment: <Pick your compartment>
    - Execution log: **Enabled**
    - Log level: **Error**
1. Click **Next** to define the route
1. Enter the following values for **Route 1**:
    - Path: **/subscribe**
    - Methods: **POST**
    - Type: **Oracle Functions**
    - Application: **mushop-app** (or other, if you used a different name)
    - Function name: **newsletter-subscription**
1. Click the **Show Route Logging Policies** link and enable **Execution Log**
1. Click **Next** and review the deployment
1. Click **Create** to create the gateway deployment

When deployment completes, navigate to it to get the URL for the gateway. Click the **Show** link next to the **Endpoint** label to reveal the full URL for the deployment. It should look like this:

```text
https://aaaaaaaaa.apigateway.us-ashburn-1.oci.customer-oci.com/newsletter/subscribe
```

You will use this URL in `values-dev.yaml` when creating the deployment. 

## Deployment

Having completed the [provisioning](#provisioning) steps above, the `mushop` deployment
helm chart is installed using settings to leverage cloud backing services.

1. Make a copy of the [`values-dev.yaml`](https://github.com/oracle-quickstart/oci-cloudnative/blob/master/deploy/complete/helm-chart/mushop/values-dev.yaml) file and store somewhere on your machine as `myvalues.yaml`. Then complete the missing values (e.g. secret names) like the following:

    ```yaml
    global:
      ociAuthSecret: oci-credentials        # OCI authentication credentials secret
      ossStreamSecret: oss-connection       # Name of Stream connection secret
      oadbAdminSecret: oadb-admin           # Name of DB Admin secret
      oadbWalletSecret: oadb-wallet         # Name of Wallet secret
      oadbConnectionSecret: oadb-connection # Name of DB Connection secret
      oosBucketSecret: oos-bucket           # Object storage bucket secret name (optional)
    ```

    > **NOTE:** If it's desired to connect a separate databases for a given service, you can specify values specific for each service, such as `carts.oadbAdminSecret`, `carts.oadbWalletSecret`...

    <aside class="notice">
    Database (<code>oadb-*</code>), stream (<code>oss-*</code>), and bucket (<code>oos-*</code>) secrets  may be omitted if using the automated service broker approach.
    </aside>

1. **Optional**: If an Object Storage bucket is provisioned, you can configure the `api` environment to use the object URL prefix in `myvalues.yaml`:

    ```yaml
    api:
      env:
        mediaUrl: # https://objectstorage.[REGION].oraclecloud.com/n/[NAMESPACE]/b/[BUCKET_NAME]/o/
    ```

1. **Optional**: If you configured the Email Delivery, API gateway and the function, add the following snippet to your `myvalues.yaml` file:

    ```yaml
    api:
      env:
        mediaUrl: # ...
        newsletterSubscribeUrl: https://[API_GATEWAY_URL]
    ```

1. Install the [`mushop`](https://github.com/oracle-quickstart/oci-cloudnative/tree/master/deploy/complete/helm-chart/mushop) application helm chart using the `myvalues.yaml` created above:
    - **OPTION 1:** With cloud services provisioned **manually**:

        ```shell--helm2
        helm install ./mushop \
          --name mushop \
          --namespace mushop \
          --values myvalues.yaml
        ```

        ```shell--helm3
        helm install mushop ./mushop \
          --namespace mushop \
          --values myvalues.yaml
        ```
    - **OPTION 2:** When using **OCI Service Broker** (`provision` chart):

        ```shell--helm2
        helm install ./mushop \
          --name mushop \
          --namespace mushop \
          --set global.osb.atp=true \
          --set global.osb.oss=true \
          --set global.osb.objectstorage=true \
          --values myvalues.yaml
        ```

        ```shell--helm3
        helm install mushop ./mushop \
          --namespace mushop \
          --set global.osb.atp=true \
          --set global.osb.oss=true \
          --set global.osb.objectstorage=true \
          --values myvalues.yaml
        ```
1. Wait for deployment pods to be **RUNNING** and init pods to show **COMPLETED**:

    ```shell
    kubectl get pods --watch
    ```

    ```text
    NAME                                  READY   STATUS      RESTARTS   AGE
    mushop-api-769c4d9fd8-hp7mc           1/1     Running     0          31s
    mushop-assets-dd5756599-pxngg         1/1     Running     0          33s
    mushop-assets-deploy-1-n2bk6          0/1     Completed   0          33s
    mushop-carts-6f5db9565f-4w65t         1/1     Running     0          33s
    mushop-carts-init-1-dcs82             0/1     Completed   0          33s
    mushop-catalogue-76977479fd-thdq4     1/1     Running     0          32s
    mushop-catalogue-init-1-twx9x         0/1     Completed   0          33s
    mushop-edge-648c989cd4-6g9dk          1/1     Running     0          32s
    mushop-events-569f4744c9-l7pqt        1/1     Running     0          30s
    mushop-fulfillment-85489cd99b-lzwqp   1/1     Running     0          30s
    mushop-nats-84dc5db659-7rpbl          1/1     Running     0          32s
    mushop-orders-6dcc7bbbb6-658tq        1/1     Running     0          33s
    mushop-orders-init-1-tm8ls            0/1     Completed   0          33s
    mushop-payment-c7dccd8cc-t9wmj        1/1     Running     0          33s
    mushop-session-5ff4c9557f-dmbq8       1/1     Running     0          33s
    mushop-storefront-8656597656-lgdlk    1/1     Running     0          33s
    mushop-user-54f4978d68-qhr7n          0/1     Running     0          31s
    mushop-user-init-1-8k62c              0/1     Completed   0          33s
    ```

1. Open a browser with the `EXTERNAL-IP` created during setup, **OR** `port-forward`
directly to the `edge` service resource:

    ```shell
    kubectl port-forward \
      --namespace mushop \
      svc/edge 8000:80
    ```

    > Using `port-forward` connecting [localhost:8000](http://localhost:8000) to the `edge` service

    ```shell
    kubectl get svc mushop-utils-nginx-ingress-controller \
      --namespace mushop-utilities
    ```

    > Locating `EXTERNAL-IP` for Ingress Controller. **NOTE** this will be
    [localhost](https://localhost) on local clusters.