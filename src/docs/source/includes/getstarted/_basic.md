## Basic Deployment

This deployment is designed to run on Oracle Cloud Infrastructure using
only **Always Free** resources. It uses MuShop source code and the Oracle Cloud Infrastructure
[Terraform Provider](https://www.terraform.io/docs/providers/oci/index.html) to
produce a [Resource Manager](https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) stack,
that _provisions_ all required resources and _configures_ the application on
those resources.

```shell--linux-macos
cd deploy/basic
```

```shell--win
dir deploy/basic
```

> Source directory for basic deployment option

These steps outline the **Basic** deployment using Resource Manager:

1. Download the latest [`mushop-basic-stack-v1.x.x.zip`](https://github.com/oracle-quickstart/oci-cloudnative/releases) file.

1. [Login](https://console.us-ashburn-1.oraclecloud.com/resourcemanager/stacks/create) to the console to import the stack.

    > Home > Solutions & Platform > Resource Manager > Stacks > Create Stack

1. Upload the `mushop-basic-stack-v1.x.x.zip` file that was downloaded earlier, and provide a name and description for the stack.

1. Specify configuration options:

    1. **Database Name** - You can choose to provide a database name (optional)
    1. **Node Count** - Select if you want to deploy one or two application instances.
    1. **Availability Domain**  - Select any availability domain to create the resources. If you run in to service limits, you could try another availability domain.

1. Review the information and click `Create` button.

    > The upload can take a few seconds, after which you will be taken to the newly created stack

1. On Stack details page, select `Terraform Actions > Apply`

<aside class="notice">
  The application is deployed to the compute instances <strong>asynchronously</strong>,
  and it may take a few minutes for the public URL to serve the application. If
  the stack is applied successfully but the application returns a
  <strong>503 Bad Gateway</strong> message, then wait a few moments and reload
  until the application comes online.
</aside>
