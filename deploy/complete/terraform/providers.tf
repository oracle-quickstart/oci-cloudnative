# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.36.0"
      # https://registry.terraform.io/providers/hashicorp/oci/4.36.0
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.2.0" # Latest version as June 2021 = 2.3.2. Using 2.2.0 (May, 2021) for ORM compatibility
      # https://registry.terraform.io/providers/hashicorp/kubernetes/2.2.0
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.1.0" # Latest version as June 2021 = 2.2.0. Using 2.1.0 (March, 2021) for ORM compatibility
      # https://registry.terraform.io/providers/hashicorp/helm/2.1.0
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0" # Latest version as June 2021 = 3.1.0.
      # https://registry.terraform.io/providers/hashicorp/tls/3.1.0
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0" # Latest version as June 2021 = 2.1.0.
      # https://registry.terraform.io/providers/hashicorp/local/2.1.0
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0" # Latest version as June 2021 = 3.1.0.
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

# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
provider "kubernetes" {
  host                   = yamldecode(local_file.kubeconfig.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(local_file.kubeconfig.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  config_context         = yamldecode(local_file.kubeconfig.content)["contexts"][0]["name"]

  exec {
    api_version = yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["apiVersion"]
    args = [yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][0],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][1],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][2],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][3],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][4],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][5],
    yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][6]]
    command = yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["command"]
  }
}

# Extra step to avoid Terraform Kubernetes provider interpolation. https://registry.terraform.io/providers/hashicorp/kubernetes/2.2.0/docs#stacking-with-managed-kubernetes-cluster-resources
resource "local_file" "kubeconfig" {
  content  = fileexists("${path.module}/generated/oke_kubeconfig") ? file("${path.module}/generated/oke_kubeconfig") : local_file.oke_kubeconfig.content
  filename = "${path.module}/generated/kubeconfig"
}

# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
provider "helm" {
  kubernetes {
    host                   = yamldecode(local_file.kubeconfig.content)["clusters"][0]["cluster"]["server"]
    cluster_ca_certificate = base64decode(yamldecode(local_file.kubeconfig.content)["clusters"][0]["cluster"]["certificate-authority-data"])
    config_context         = yamldecode(local_file.kubeconfig.content)["contexts"][0]["name"]

    exec {
      api_version = yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["apiVersion"]
      args = [yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][0],
        yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][1],
        yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][2],
        yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][3],
        yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][4],
        yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][5],
      yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["args"][6]]
      command = yamldecode(local_file.kubeconfig.content)["users"][0]["user"]["exec"]["command"]
    }
  }
}
