# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 0.14"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.20.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "1.4.0" # Latest version as March 2021 = 2.1.0. Using 1.4.0 (September, 2019) for ORM compatibility
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.0" # Latest version as March 2021 = 3.1.0. Using 2.3.0 (July, 2020) for ORM compatibility
    }
    template = {
      source = "hashicorp/template"
      version = "2.1.2" # (Deprecated) Latest version as March 2021 = 2.2.0. Using 2.3.0 (July, 2020) for ORM compatibility
    }
    tls = {
      source  = "hashicorp/tls"
      version = "2.0.1" # Latest version as March 2021 = 3.1.0. Using 2.0.1 (April, 2020) for ORM compatibility
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = local.region_to_deploy

  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
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

locals {
  region_to_deploy = var.use_only_always_free_eligible_resources ? lookup(data.oci_identity_regions.home_region.regions[0], "name") : var.region
}