# CHANGELOG

2021-04-07 (v2.2.0)

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

- Hability to enable/disable the deployment option of the common services of MuShop Utilities

2020-06-03

- Hability to re-use an existent OKE cluster
- schema updated to reflect the terraform scripts feature for OKE new vs existent

2020-06-02

- MuShop Utilities charts updated to the latest
- updated the helm_repository terraform resource to be ready for the next major update (Removal/replacement of the to-be-deprecated resources)

2020-05-21

- Terraform scripts to deploy OKE and MuShop App without manual steps
- Oracle Resource Manager (ORM) stack for easy deployment using the OCI console
- Deployment of the Oracle Autonomous Database Trasaction Processing (ATP) for MuShop data
