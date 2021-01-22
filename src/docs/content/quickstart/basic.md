---
title: "Always Free"
date: 2020-03-06T12:28:12-07:00
draft: false
weight: 10
tags:
  - Free
  - Terraform
  - Resource Manager
  - ATP
---

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

> Source directory for basic deployment build/configuration

These steps outline the **Basic** deployment using Resource Manager:

1. Download the latest [`mushop-basic-stack-latest.zip`](https://github.com/oracle-quickstart/oci-cloudnative/releases) file.
1. [Login](https://cloud.oracle.com/resourcemanager/stacks/create) to the console to import the stack.
    > Home > Solutions & Platform > Resource Manager > Stacks > Create Stack
1. Upload the `mushop-basic-stack-latest.zip` file that was downloaded earlier, and provide a name and description for the stack.
1. Specify configuration options:
   1. **Database Name** - You can choose to provide a database name (optional)
   1. **Node Count** - Select if you want to deploy one or two application instances.
   1. **SSH Public Key** - (Optional) Provide a public SSH key if you wish to establish SSH access to the compute node(s).
1. Review the information and click `Create` button.
    > The upload can take a few seconds, after which you will be taken to the newly created stack
1. On Stack details page, select `Terraform Actions > Apply`

{{% alert icon="info" %}}
The application is deployed to the compute instances **asynchronously**.
It may take a few minutes for the public URL to serve the application. If
the stack is applied successfully but the application returns a
**503 Bad Gateway** message, then wait a few moments and reload
until the application comes online.
{{% /alert %}}
