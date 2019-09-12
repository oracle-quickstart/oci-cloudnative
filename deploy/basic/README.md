![MuShop Logo](../../images/logo.png)

This is a Terraform configuration that deploys the MuShop Basic demo on [Oracle Cloud Infrastructure (OCI)][oci]. 

MuShop Basic is a sample 3-tier web application that implements an e-commerce site. It is built to showcase the features of [Oracle Cloud Infrastructure (OCI)][oci]. This sample is designed to run using only the Always Free tier resources. This sample contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack. This stack creates all the required resources and configures the application on the created resources.

## Topology

The application uses a typical topology for a 3-tier web application as follows
![MuShop Basic Infra](../../images/basic/00-Topology.png)

### Components

| Component             | What                                                                                                                             | Why                                                                                                                                                                                                                                    |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Compute Instances     | 1..2 Free-Tier eligible compute instance                                                                                         | These VMs host the application                                                                                                                                                                                                         |
| Autonomous Database   | 1 Free-Tier eligible Autonomous Database instance                                                                                | The database used by the application                                                                                                                                                                                                   |
| Load Balancer         | 1 Free-Tier eligible load balancer [Learn More][lb]                                                                              | Routes traffic between the nodes hosting the application                                                                                                                                                                               |
| Virtual Cloud Network | Provides a virtual network in the cloud [Learn More][vcn]                                                                        | The virtual network used by the sample to host all its networking components                                                                                                                                                           |
| Private Subnet        | A subnet within the network that does not allow the network components to have publicly reachable IP addresses [Learn More][vcn] | The private subnet is used to house the compute instances. Being private, they ensure that the application nodes are not exposed to the internet                                                                                       |
| Public Subnet         | A subnet that allows public IPs. [Learn More][vcn]                                                                               | The subnet that houses the public load balancer. Public IP addresses allowed                                                                                                                                                           |
| Internet Gateway      | A virtual router that allows direct internet access. [Learn More][igw]                                                           | This enables the load balancer to be reachable from the internet.                                                                                                                                                                      |
| NAT Gateway           | A virtual router that allows internet access without exposing the source directly to the internet [Learn More][natgw]            | It gives the compute instances (with no public IP addresses) access to the internet without exposing them to incoming internet connections.                                                                                            |
| Service Gateway       | A virtual router that enables private traffic to OCI services from a VCN [Learn More][svcgw]                                     | Provides a path for private network traffic between your VCN and services like Object Storage or ATP.                                                                                                                                  |
| Route Tables          | Route tables route traffic that leaves the VCN. [Learn More][rt]                                                                 | The public subnet route rules direct traffic to use the Internet Gateway, while the private subnet route rules enable the compute instances to reach the internet through the NAT gateway and OCI services through the service gateway |
| Security Lists        | They act like a firewall with the rules determining what type of traffic is allowed in or out.[Learn More][seclist]              | Security rules enable HTTP traffic to the LoadBalancer from anywhere. Also enables are HTTP and SSH traffic to the compute instances, but only from the subnet where the load balancer is.                                             |

## Build

- Clone https://github.com/oracle/oci-quickstart-cloudnative
- From the root of the repo execute the command:
  
 `docker build -t mushop-basic -f deploy/basic/Dockerfile .`

- Generate Stack Zip Package for OCI Resource Manager

`docker run -v $PWD:/transfer --rm --entrypoint cp mushop-basic:latest /package/mushop-basic.zip /transfer/mushop-basic.zip`

This creates a `.zip` file in your working directory that can be imported in to OCI Resource Manager.

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