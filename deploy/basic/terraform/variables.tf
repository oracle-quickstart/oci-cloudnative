# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

variable "public_ssh_key" {
  default = ""
}

# Compute
variable "num_nodes" {
  default = 2
}
variable "generate_public_ssh_key" {
  default = true
}
variable "instance_shape" {
  default = "VM.Standard.E3.Flex"
}
variable "instance_ocpus" {
  default = 1
}
variable "instance_shape_config_memory_in_gbs" {
  default = 16
}
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "7.9"
}
variable "instance_visibility" {
  default = "Public"
}
variable "is_pv_encryption_in_transit_enabled" {
  default = false
}

# Network Details
variable "lb_shape" {
  default = "flexible"
}
variable "lb_shape_details_minimum_bandwidth_in_mbps" {
  default = 10
}
variable "lb_shape_details_maximum_bandwidth_in_mbps" {
  default = 100
}
variable "lb_compartment_ocid" {
  default = ""
}
variable "create_secondary_vcn" {
  default = false
}
variable "create_lpg_policies_for_group" {
  default = false
}
variable "user_admin_group_for_lpg_policy" {
  default = "Administrators"
}
variable "network_cidrs" {
  type = map(string)

  default = {
    MAIN-VCN-CIDR                = "10.1.0.0/16"
    MAIN-SUBNET-REGIONAL-CIDR    = "10.1.21.0/24"
    MAIN-LB-SUBNET-REGIONAL-CIDR = "10.1.22.0/24"
    LB-VCN-CIDR                  = "10.2.0.0/16"
    LB-SUBNET-REGIONAL-CIDR      = "10.2.22.0/24"
    ALL-CIDR                     = "0.0.0.0/0"
  }
}

# Autonomous Database
variable "autonomous_database_name" {
  default = "MuShopDB"
}
variable "autonomous_database_db_version" {
  default = "19c"
}
variable "autonomous_database_license_model" {
  default = "LICENSE_INCLUDED"
}
variable "autonomous_database_is_free_tier" {
  default = false
}
variable "autonomous_database_cpu_core_count" {
  default = 1
}
variable "autonomous_database_data_storage_size_in_tbs" {
  default = 1
}
variable "autonomous_database_visibility" {
  default = "Public"
}
variable "autonomous_database_wallet_generate_type" {
  default = "SINGLE"
}
variable "oracle_client_version" {
  default = "19.8"
}

# Encryption (OCI Vault/Key Management/KMS)
variable "use_encryption_from_oci_vault" {
  default = false
}
variable "create_new_encryption_key" {
  default = true
}
variable "encryption_key_id" {
  default = ""
}
variable "create_vault_policies_for_group" {
  default = false
}
variable "user_admin_group_for_vault_policy" {
  default = "Administrators"
}
variable "vault_display_name" {
  default = "MuShop Vault"
}
variable "vault_type" {
  type    = list(any)
  default = ["DEFAULT", "VIRTUAL_PRIVATE"]
}
variable "vault_key_display_name" {
  default = "MuShop Key"
}
variable "vault_key_key_shape_algorithm" {
  default = "AES"
}
variable "vault_key_key_shape_length" {
  default = 32
}

# ORM Schema visual control variables
variable "show_advanced" {
  default = false
}

# Object Storage
variable "object_storage_mushop_media_compartment_ocid" {
  default = ""
}
variable "object_storage_mushop_media_visibility" {
  default = "Public"
}

# MuShop Services
variable "services_in_mock_mode" {
  default = "carts,orders,users"
}

# Always Free only or support other shapes
variable "use_only_always_free_elegible_resources" {
  default = true
}
## Always Free Locals
locals {
  instance_shape                             = var.use_only_always_free_elegible_resources ? local.compute_shape_micro : var.instance_shape
  lb_shape                                   = var.use_only_always_free_elegible_resources ? local.lb_shape_flexible : var.lb_shape
  lb_shape_details_minimum_bandwidth_in_mbps = var.use_only_always_free_elegible_resources ? 10 : var.lb_shape_details_minimum_bandwidth_in_mbps
  lb_shape_details_maximum_bandwidth_in_mbps = var.use_only_always_free_elegible_resources ? 10 : var.lb_shape_details_maximum_bandwidth_in_mbps
  autonomous_database_is_free_tier           = var.use_only_always_free_elegible_resources ? true : var.autonomous_database_is_free_tier
}

# Shapes
locals {
  compute_shape_micro = "VM.Standard.E2.1.Micro"
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
  compute_shape_flexible_descriptions = [
    "Cores for Standard.E3.Flex and BM.Standard.E3.128 Instances",
    "Cores for Standard.E4.Flex and BM.Standard.E4.128 Instances"
  ]
  compute_shape_flexible_vs_descriptions = zipmap(local.compute_flexible_shapes, local.compute_shape_flexible_descriptions)
  compute_shape_description              = lookup(local.compute_shape_flexible_vs_descriptions, local.instance_shape, local.instance_shape)
  lb_shape_flexible                      = "flexible"
}
