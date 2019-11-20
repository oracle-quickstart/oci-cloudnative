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
   and is **not** recommended in most real-world use cases.
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

## Provision

The included `provision` chart is an application of the open-source [OCI Service Broker](https://github.com/oracle/oci-service-broker)
for _provisioning_ Oracle Cloud Infrastructure services. This implementation utilizes [Open Service Broker](https://github.com/openservicebrokerapi/servicebroker/blob/v2.14/spec.md) in Oracle Container Engine for Kubernetes or in other Kubernetes clusters.

```text
cd deploy/complete/helm-chart
```

1. The Service Broker for Kubernetes requires tenancy credentials to provision and
manage services from within the cluster. Create a secret containing these
values:

    ```shell
    kubectl create secret generic oci-service-broker \
      --namespace mushop \
      --from-literal=tenancy=<TENANCY_OCID> \
      --from-literal=user=<USER_OCID> \
      --from-literal=region=<USER_OCI_REGION> \
      --from-literal=fingerprint=<PUBLIC_API_KEY_FINGERPRINT> \
      --from-literal=passphrase=<PRIVATE_API_KEY_PASSPHRASE> \
      --from-file=privatekey=<PATH_OF_PRIVATE_API_KEY>
    ```

1. Deploy the OCI service broker on your cluster. This is done with the [Oracle OCI Service Broker](https://github.com/oracle/oci-service-broker) helm chart:

    ```shell
    helm install https://github.com/oracle/oci-service-broker/releases/download/v1.3.1/oci-service-broker-1.3.1.tgz \
      --namespace mushop \
      --name oci-service-broker \
      --set ociCredentials.secretName=oci-service-broker \
      --set storage.etcd.useEmbedded=true \
      --set tls.enabled=false
    ```

    > The above command will deploy the OCI Service Broker using an embedded etcd instance. It is not recommended to deploy the OCI Service Broker using an embedded etcd instance and tls disabled in production environments, instead a separate etcd cluster should be setup and used by the OCI Service Broker.

1. Now establish the link between Service Catalog and the OCI Service Broker implementation by installing the `provision` chart:

    ```shell
    helm install provision \
      --namespace mushop \
      --name mushop-provision \
      --set skip.ociCredentials=true \
      --set global.osb.compartmentId=<compartmentId>
    ```

    > Note that `ociCredentials` were created previously

1. Verify `serviceinstances` and `servicebindings` are **READY**

    ```text
    kubectl get serviceinstances -A
    ```

    ```text
    kubectl get servicebindings -A
    ```

## Deploy

Having completed the [Provisioning](#provision) steps above, the `mushop` deployment
helm chart is used with settings to leverage cloud backing services and their resulting
`servicebindings` with connection information

```shell
helm install mushop \
  --namespace mushop \
  --name mushop \
  --set global.osb.atp=true \
  --set skip.streaming=true
```

<aside class="notice">
  The above command includes <code>--skip.streaming=true</code> indicating that the Streaming
  configurations should be excluded. Refer to details in <a href="https://github.com/oracle-quickstart/oci-cloudnative/blob/master/deploy/complete/helm-chart/mushop/values.yaml">values.yaml</a> for information on connecting to the Streaming service
</aside>
