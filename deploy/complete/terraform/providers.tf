# Copyright (c) 2020-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.85.0"
      # https://registry.terraform.io/providers/hashicorp/oci/4.85.0
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.2.0" # Latest version as January 2022 = 2.7.1. Using 2.2.0 (May, 2021) for ORM compatibility (12 releases behind)
      # https://registry.terraform.io/providers/hashicorp/kubernetes/2.2.0
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.1.0" # Latest version as January 2022 = 2.4.1. Using 2.1.0 (March, 2021) for ORM compatibility (7 releases behind)
      # https://registry.terraform.io/providers/hashicorp/helm/2.1.0
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0" # Latest version as January 2022 = 3.1.0.
      # https://registry.terraform.io/providers/hashicorp/tls/3.1.0
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0" # Latest version as January 2022 = 2.1.0.
      # https://registry.terraform.io/providers/hashicorp/local/2.1.0
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0" # Latest version as January 2022 = 3.1.0.
      # https://registry.terraform.io/providers/hashicorp/random/3.1.0
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

provider "oci" {
  alias        = "home_region"
  tenancy_ocid = var.tenancy_ocid
  region       = lookup(data.oci_identity_regions.home_region.regions[0], "name")

  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

provider "oci" {
  alias        = "current_region"
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# New configuration to avoid Terraform Kubernetes provider interpolation. https://registry.terraform.io/providers/hashicorp/kubernetes/2.2.0/docs#stacking-with-managed-kubernetes-cluster-resources
# Currently need to uncheck to refresh (--refresh=false) when destroying or else the terraform destroy will fail

# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
    command     = "oci"
  }
}

# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
      command     = "oci"
    }
  }
}

locals {
  cluster_endpoint       = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
  cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
}
