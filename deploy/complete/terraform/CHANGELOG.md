# CHANGELOG

2022-02-02 (v3.1.0)

- Terraform OCI Provider Updated to the latest
- Updates the Cluster Utilities Helm charts versions
- Updated Kubernetes versions available (1.21.5, 1.20.11 and 1.19.15). "Latest" will always get the latest available, even if not listed.
- Cluster Autoscaler updated to follow new versioning structure
- Oracle Digital Assistant support on the storefront
- Initial arm64 shapes for nodes support

2021-07-28 (v3.0.1)

- Terraform OCI Provider Updated to the latest
- Updates the Cluster Utilities Helm charts versions
- Updated Kubernetes versions available (1.20.8, 1.19.12 and 1.18.10). "Latest" will always get the latest available, even if not listed.
- Change the default deployment behavior of the Functions to False.

    **Note:** only supports the Ashburn-1 region (Temporary workaround until next drop that will support all regions for Functions. Limitation on the Oracle Function deployment)

2021-06-22 (v3.0.0)

- Updated to use Terraform 1.0.x
- Sensitive fields special treatment
- Terraform providers updated to use newer supported versions. (ORM now is supporting the latest)
- Removal of compatibility workarounds for old/deprecated TF providers

2021-06-09 (v2.4.0)

- E-mail newsletter service included on the stack
- Leveraging and automatically deploying OCI API Gateway (newsletter)
- Leveraging and automatically deploying OCI Functions (newsletter)
- Leveraging OCI Email Delivery (newsletter)
- Multi-arch support for Catalogue Service (amd64 and Arm64)
- Multi-arch support for Payment Service (amd64 and Arm64)
- Multi-arch support for Assets Service (amd64 and Arm64)
- Multi-arch support for Storefront Service (amd64 and Arm64)
- Multi-arch support for API Service (amd64 and Arm64)
- Multi-arch support for dbtools (amd64 and Arm64)
- Policies improved
- Cluster Utilities versions updated
- Multiple small improvements and fixes
- DB scripts improvements
- catalogue service tweaks

2021-05-18 (v2.3.0)

- Support for flexible Load Balancer annotations on Ingress-Nginx
- Support for domain name (FQDN) for ingress
- Better variables and schema for Certificate management
- Cert-manager updates
- Schema updates for Ingress new features
- Cluster Utilities version updates
- apiVersion and manifest updates on deprecated items

2021-04-08 (v2.2.0)

- OKE Cluster Autoscaler support
- Improved KMS support
- Private Kubernetes API Endpoint support from standalone Terraform
- App Name usage updated

2021-04-02 (v2.1.0)

- Retrieval of Current and Home regions for Identity requests
- Support for versioning TF providers
- Support for OLD TF Providers to match ORM support
- Support for new E4.flex shapes
- Terraform Variables validation
- Helm chart updates: remove deprecated Grafana oci-datasource
- Introduction to OCI Metrics and OCI Logging plugins for Grafana
- Pre-configured OCI Metrics and OCI Logging datasources
- New pre-loaded Grafana Dashboards
- Subject-oriented terraform variables
- Option to create a new sub-compartment for OKE, Nodes, Services
- Kubernetes API Endpoint options (Public or Private)
- Terraform resources re-organized
- Revamped ORM Schema
- KMS/OCI Vault initial support

2021-03-11 (v2.0.6)

- Helm Repo Repos updated
- Terraform updated to 0.14
- Terraform Providers updated
- ORM Schema updated
- Fixes and improvements
- Supporting services updated
- Support for more flex shapes
- DB Profile for password settings for services schema

2021-01-15 (v2.0.5)

- Helm Repo Repos updated
- Terraform updated to 0.13
- Terraform Providers updated
- ORM Schema updated
- Fixes and improvements
- Ability to change lb shapes for the ingress
- Supporting services updated

2020-06-10

- Ability to enable/disable the deployment option of the common services of MuShop Utilities

2020-06-03

- Ability to re-use an existent OKE cluster
- schema updated to reflect the terraform scripts feature for OKE new vs existent

2020-06-02

- MuShop Utilities charts updated to the latest
- updated the helm_repository terraform resource to be ready for the next major update (Removal/replacement of the to-be-deprecated resources)

2020-05-21

- Terraform scripts to deploy OKE and MuShop App without manual steps
- Oracle Resource Manager (ORM) stack for easy deployment using the OCI console
- Deployment of the Oracle Autonomous Database Transaction Processing (ATP) for MuShop data
