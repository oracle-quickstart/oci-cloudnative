# oci-quickstart-cloudnative

![MuShop Logo](./images/logo.png)

This is a Terraform configuration that deploys the MuShop demo on [Oracle Cloud Infrastructure (OCI)][oci].  They are developed by Oracle.

MuShop is a sample 3-tier web application that implements an e-commerce site. It is built to showcase the features of [Oracle Cloud Infrastructure (OCI)][oci]. This sample is designed to run using only the Always Free tier resources. This sample contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack. This stack creates all the required resources and configures the application on the created resources.

## Topology

The application uses a typical topology for a 3-tier web application as follows
![MuShop Lite Infra](./images/basic/00-Topology.png)

### Components

| Component             | What                                              | Why                                                                                                                                              |
| --------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Compute Instances     | 1..2 Free-Tier eligible compute instance          | These VMs host the application                                                                                                                   |
| Autonomous Database   | 1 Free-Tier eligible Autonomous Database instance | The database used by the application                                                                                                             |
| Load Balancer         | 1 Free-Tier eligible load balancer                | Routes traffic between the nodes hosting the application                                                                                         |
| Virtual Cloud Network | [Learn More][vcn]                                 | The virtual network used by the sample to host all its networking components                                                                     |
| Private Subnet        | [Learn More][vcn]                                 | The private subnet is used to house the compute instances. Being private, they ensure that the application nodes are not exposed to the internet |
| Public Subnet         | [Learn More][vcn]                                 | The subnet that houses the public load balancer. Public IP addresses allowed                                                                     |
| Internet Gateway      | [Learn More][vcn]                                 | A virtual router attached tot he public subnet. allws direct internet acces. This enables the loadbalancer to be reachable from the internet.    |
| NAT Gateway           | [Learn More][vcn]                                 | It gives the compute instances (with no public IP addresses) access to the internet without exposing them to incoming internet connections.      |
| Service Gateway       | [Learn More][vcn]                                 | provides a path for private network traffic between your VCN and services likeObject Storage or ATP.                                             |

## Deployment

* [basic](deploy/basic/terraform) deploys the lite version of MuShop, light enough to run on the Always Free tier. Deploys the UI (Storefront), API service and the Catalogue service connected to the ATP.

Please follow the instructions in [basic](deploy/basic/terraform) folders to deploy.

![MuShop Lite Infra](./images/basic/00-Free-Tier.png)

## License

Copyright © 2019, Oracle and/or its affiliates. All rights reserved.

The Universal Permissive License (UPL), Version 1.0

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[tf]: https://www.terraform.io
[net]: https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm
[vcn]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingVCNs.htm
