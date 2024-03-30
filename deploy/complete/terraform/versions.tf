# Copyright (c) 2024, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

terraform {
  required_version = ">= 1.2" #>= 1.6 when using OpenTofu
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5"
      # https://registry.terraform.io/providers/oracle/oci/
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
      # https://registry.terraform.io/providers/hashicorp/kubernetes/
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
      # https://registry.terraform.io/providers/hashicorp/helm/
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4"
      # https://registry.terraform.io/providers/hashicorp/tls/
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
      # https://registry.terraform.io/providers/hashicorp/local/
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
      # https://registry.terraform.io/providers/hashicorp/random/
    }
  }
}