---
title: "Prerequisites"
date: 2020-03-09T14:51:01-06:00
weight: -10
tags:
  - Region
  - Compartment
  - Policies
  - API Key
---

In order connect the MuShop application with services in Oracle Cloud Infrastructure,
several configurations are necessary. These tenancy configurations will be used to
properly provision and/or connect cloud services: Create a file with the following
information to simplify lookups later:

```yaml
region:       # Region where resources will be provisioned (ex us-phoenix-1)
tenancy:      # Tenancy OCID value
user:         # API User OCID value
compartment:  # Compartment OCID value
key:          # Private API Key file path (ex /Users/jdoe/.oci/oci_key.pem)
fingerprint:  # Public API Key fingerprint (ex 43:65:2c...)
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

    {{% alert style="danger" icon="warning" %}}
    This policy is intentionally broad for the sake of simplicity,
    and is **not** recommended in most real-world use cases.
    Refer to the [Documentation](https://docs.cloud.oracle.com/iaas/Content/Identity/Concepts/overview.htm#three) for more on this topic.
    {{% /alert %}}

### Service Limits

Deploying the full application requires services from Oracle Cloud
Infrastructure. Use of these services will be subject to Service Limits in your
tenancy. Check minimum resource availability as follows:

> Check limits in the Console: Governance and Admininstration » Governance » Limits, Quotas, and Usage

| Service | Resource | Requirement |
| -- | -- | -- |
| Autonomous Transaction Processing Database | OCPU Count | `>=1` |
| Streaming | Partition Count | `>=1` |

{{% alert style="primary" icon="info" %}}
This does not include requirements in cases where OKE is used.
{{% /alert %}}
