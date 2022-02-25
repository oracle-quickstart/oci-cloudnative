# ![MuShop Logo](../../images/logo.png#gh-light-mode-only)![MuShop Logo - Dark Mode](../../images/logo-inverse.png#gh-dark-mode-only)        [![Deploy to Oracle Cloud][magic_button]][magic_mushop_basic_stack]

This is a Terraform configuration that deploys the MuShop basic sample application on [Oracle Cloud Infrastructure (OCI)][oci].

MuShop basic is a 3-tier web application that implements an e-commerce site.
It is built to showcase the features of [Oracle Cloud Infrastructure (OCI)][oci].
This application is designed to run using only the Always Free tier resources.
The repository contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack,
that creates all the required resources and configures the application on the created resources.

## Topology

The application uses a typical topology for a 3-tier web application as follows

![MuShop Basic Infra](../../images/basic/00-Topology-v1.2.0.svg)

### Components

| Component             | What                                                                                                           | Why                                                                                                                                                                                                                                    | Learn                 |
| --------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| Compute Instances     | 1 or 2 Always Free tier eligible compute instance                                                              | These VMs host the application                                                                                                                                                                                                         | [Learn More][inst]    |
| Autonomous Database   | 1 Always Free tier eligible Autonomous Database instance                                                       | The database used by the application                                                                                                                                                                                                   | [Learn More][adb]     |
| Vault                 | Optional use of OCI Vault keys for Key Management (KMS).       | Encrypt boot volumes of the compute instances and Object Storage buckets.                                             | [Learn More][kms] |
| Load Balancer         | 1 Always Free tier eligible load balancer                                                                      | Routes traffic between the nodes hosting the application                                                                                                                                                                               | [Learn More][lb]      |
| Virtual Cloud Network | This resource provides a virtual network in the cloud                                                          | The virtual network used by the application to host all its networking components                                                                                                                                                      | [Learn More][vcn]     |
| Private Subnet        | A subnet within the network that does not allow the network components to have publicly reachable IP addresses | The private subnet is used to house the compute instances. Being private, they ensure that the application nodes are not exposed to the internet                                                                                       | [Learn More][vcn]     |
| Public Subnet         | A subnet that allows public IPs.                                                                               | The subnet that houses the public load balancer. Components in this subnet can be allocated public IP addresses and be exposed to the internet through the InternetGateway.                                                            | [Learn More][vcn]     |
| Internet Gateway      | A virtual router that allows direct internet access.                                                           | This enables the load balancer to be reachable from the internet.                                                                                                                                                                      | [Learn More][igw]     |
| NAT Gateway           | (Not available on Always-free only) A virtual router that allows internet access without exposing the source directly to the internet              | It gives the compute instances (with no public IP addresses) access to the internet without exposing them to incoming internet connections.                                                                                            | [Learn More][natgw]   |
| Service Gateway       | (Not available on Always-free only) A virtual router that enables private traffic to OCI services from a VCN                                       | Provides a path for private network traffic between your VCN and services like Object Storage or ATP.                                                                                                                                  | [Learn More][svcgw]   |
| Route Tables          | Route tables route traffic that leaves the VCN.                                                                | The public subnet route rules direct traffic to use the Internet Gateway, while the private subnet route rules enable the compute instances to reach the internet through the NAT gateway and OCI services through the service gateway | [Learn More][rt]      |
| Security Lists        | Security Lists act like a firewall with the rules determining what type of traffic is allowed in or out.       | Security rules enable HTTP traffic to the LoadBalancer from anywhere. Also enables are HTTP and SSH traffic to the compute instances, but only from the subnet where the load balancer is.                                             | [Learn More][seclist] |

## Build

### Build to generate stack (Stack will contain amd64 and arm64 binaries)

1. Clone <https://github.com/oracle/oci-quickstart-cloudnative>
1. From the root of the repo execute the command:

    * Create the Multi-Arch builder if not already created

        ```shell
        docker buildx create --name multibuilder
        docker buildx use multibuilder
        ```

    * Build image

        ```shell
        docker buildx build --pull --rm --load -t mushop-basic -f deploy/basic/Dockerfile .
        ```

1. Generate Stack Zip Package for OCI Resource Manager

    ```shell
    docker run -v $PWD:/transfer --rm --entrypoint cp mushop-basic:latest /package/mushop-basic-stack.zip /transfer/mushop-basic-stack.zip
    ```

    or under Windows powershell:

    ```shell
    docker run -v "$((pwd).path -replace '\\', '/'):/transfer" --rm --entrypoint cp mushop-basic:latest /package/mushop-basic-stack.zip /transfer/mushop-basic-stack.zip
    ```

This creates a `.zip` file in your working directory that can be imported in to OCI Resource Manager.

### Build to run services locally. Multi-Arch (Example: linux/amd64, linux/arm64)

1. Clone <https://github.com/oracle/oci-quickstart-cloudnative>
1. From the root of the repo execute the command:

    * Create the Multi-Arch builder if not already created

        ```shell
        docker buildx create --name multibuilder
        docker buildx use multibuilder
        ```

    * Create the Multi-Arch builder if not already created

        ```shell
        docker buildx build --pull --rm --load -t mushop-basic -f deploy/basic/Dockerfile .
        ```

1. Run locally

    ```shell
    docker run --rm -it -p 8888:80 mushop-basic:latest
    ```

1. Browse to http://localhost:8888

## Deploying using local or OCI CloudShell *Terraform* instead of ORM stack

After complete the Build steps 1 and 2, generate the binaries:

1. From the root of the repo execute the command:

    ```shell
    docker run -v $PWD:/transfer --rm --entrypoint cp mushop-basic:latest /package/mushop-basic.tar.xz /transfer/deploy/basic/terraform/scripts/mushop-basic.tar.xz
    ```

1. Copy mushop media images to populate the object storage:

    ```shell
    docker run -v $PWD:/transfer --rm --entrypoint cp mushop-basic:latest -vr /basic/images/ /transfer/deploy/basic/terraform/
    ```

1. Go to `$PWD/deploy/basic/terraform/`
1. Rename the file `terraform.tfvars.example` to `terraform.tfvars`
1. Change the credentials variables to your user and any other desirable variables
1. Run `terraform init` to init the terraform providers
1. Run `terraform apply` to create the resources on OCI
1. To show sensitive outputs, use `terraform output autonomous_database_password` to show the ATP Admin password and `terraform output generated_private_key_pem` to show the private key for SSH access

## Running MuShop Basic APIs on Postman

Testing MuShop Basic Services APIs with Postman.

Note that these calls are intent to connect to the API endpoint, normally the ip address generated on the Load Balancer.

| Service                                                  | Postman                                                                        |
| -------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [catalogue](./src/catalogue)                             | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_catalogue] |
| [user](./src/user)                                       | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_user]      |
| [payment](./src/payment)                                 | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_payment]   |
| [api](./src/api)                                         | [![Run in Postman](https://run.pstmn.io/button.svg)][postman_button_api]       |

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
[magic_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg
[magic_mushop_basic_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-cloudnative/releases/latest/download/mushop-basic-stack-latest.zip
[postman_button_catalogue]: https://god.gw.postman.com/run-collection/29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1?action=collection%2Ffork&collection-url=entityId%3D29850-a9fbedc3-2178-442c-9bee-7fd8c52194b1%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_user]: https://god.gw.postman.com/run-collection/29850-d02fc1f5-cec7-4f00-9f25-092e64e7f726?action=collection%2Ffork&collection-url=entityId%3D29850-d02fc1f5-cec7-4f00-9f25-092e64e7f726%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_payment]: https://god.gw.postman.com/run-collection/29850-cd57303a-f3df-4a22-8e18-09cd2218d94a?action=collection%2Ffork&collection-url=entityId%3D29850-cd57303a-f3df-4a22-8e18-09cd2218d94a%26entityType%3Dcollection%26workspaceId%3D8e00caeb-8484-4be3-aa3c-3c3721e169b7
[postman_button_api]: ()
