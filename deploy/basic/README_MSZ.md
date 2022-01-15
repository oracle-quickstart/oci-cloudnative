# ![MuShop Logo](../../images/logo.png#gh-light-mode-only)![MuShop Logo - Dark Mode](../../images/logo-inverse.png#gh-dark-mode-only)

This document shows information on how to use MuShop Basic to deploy on OCI Maximum-Security Zones (MSZ) and use Cloud Guard.

## Topology

This is the topology using MSZ

![MuShop Basic Infra MSZ](../../images/basic/00-Topology-v1.2.0.MSZ.svg)

## Usage

If using the ORM stack, select advanced and the optional options to make things private, including create a secondary vcn.

If using local Terraform or on CloudShell:

- Follow the build instructions from [here (MuShop Basic Build)](https://github.com/oracle-quickstart/oci-cloudnative/blob/master/deploy/basic/README.md#build)
- On the "Rename the file" item, use the `tf_msz.tfvars.example` to rename to `terraform.tfvars`

- Change the credentials variables to your user and any other desirable variables
- Run `terraform init` to init the terraform providers
- Run `terraform apply` to create the resources on OCI

You can also include Web Application Firewall (WAF), DNS or other components as desired:

![MuShop Basic Infra MSZ Demo](../../images/basic/00-Topology-v1.2.0.MSZ-demo.svg)

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[tf]: https://www.terraform.io
[net]: https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/overview.htm
[vcn]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingVCNs.htm
[lb]: https://docs.cloud.oracle.com/iaas/Content/Balance/Concepts/balanceoverview.htm
[igw]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingIGs.htm
[natgw]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/NATgateway.htm
[svcgw]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/servicegateway.htm
[rt]: https://docs.cloud.oracle.com/iaas/Content/Network/Tasks/managingroutetables.htm
[seclist]: https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/securitylists.htm
[adb]: https://docs.cloud.oracle.com/iaas/Content/Database/Concepts/adboverview.htm
[inst]: https://docs.cloud.oracle.com/iaas/Content/Compute/Concepts/computeoverview.htm
[kms]: https://docs.cloud.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm
