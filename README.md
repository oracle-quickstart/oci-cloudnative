# oci-quickstart-cloudnative

![MuShop Logo](./images/logo.png)

This is a Terraform configuration that deploys the MuShop demo on [Oracle Cloud Infrastructure (OCI)][oci].  They are developed by Oracle.

MuShop is a sample 3-tier web application that implements an e-commerce site. It is built to showcase the features of [Oracle Cloud Infrastructure (OCI)][oci]. This sample is designed to run using only the Always Free tier resources. This sample contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack. This stack creates all the required resources and configures the application on the created resources.

## Getting Started

- Download the [latest release](https://github.com/oracle/oci-quickstart-cloudnative/releases)
- [Login to OCI](https://console.us-phoenix-1.oraclecloud.com/resourcemanager/stacks)
- Navigate to Resource Manager. `Home > Solutions & Platform > Resource Manager > Stacks`
- Choose a compartment (optional)
- Create Stack
- Drop in the .zip file that was downloaded earlier, and provide a name & description for the stack
- Configure the stack
  - Database Name - You can choose to provide a database name (optional)
  - Node count - Select if you want to deploy one or two application instances.
  - Availability Domain  - select any availability domain to create the resources. If you run in to service limits, you could try another availability domain.
- Review the information and click Create. (The upload can take a few seconds, after which you will be taken to the newly created stack)
- On the stack, click on `Terraform Actions > Plan`.
  - A terraform plan will run and tell you what resources will be created.
- Click on `Terraform Actions > Apply`
  - All the resources will be created, and the URL to the load balancer will be displayed.
  - Note that the application is being deployed to the compute instances asynchronously, and it may take a couple of minutes for the URL to serve the application.

## License

Copyright © 2019, Oracle and/or its affiliates. All rights reserved.

The Universal Permissive License (UPL), Version 1.0