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
  compute_shape_micro                = "VM.Standard.E2.1.Micro"
  compute_flexible_shapes           = ["VM.Standard.E3.Flex"]
  compute_shape_flexible_description = "Cores for Standard.E3.Flex and BM.Standard.E3.128 Instances"
  lb_shape_flexible                  = "flexible"
}

# Additional stuff for extra demo (DNS, Cert, WAF, Traffic)
# DNS Entries
variable "enable_dns_zone" {
  default = false
}

variable "dns_lb_entry" {
  default = "internal-lb"
}

variable "dns_waf_entry" {
  default = "store"
}

locals {
  dns_lb_domain = "${var.dns_lb_entry}.${var.dns_zone_name}"
  dns_waf_domain = "${var.dns_waf_entry}.${var.dns_zone_name}"
}

# Certificate
variable "certificate_certificate_name" {
  default = "mushop-lets-encrypt-certificate"
}

variable "enable_acme_certificate" {
  default = false
}

variable "acme_email" {
  default = ""
}

variable "acme_server_url" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "dns_zone_name" {
  default = "mushop.agregory.page"
}

variable "enable_waf" {
  default = "false"
}

# CAPTCHA variables

variable "enable_captcha_challenge" {
  default = "false"
}

variable "waas_policy_waf_config_captchas_failure_message" {
  default = "Incorrect CAPTCHA"
}

variable "waas_policy_waf_config_captchas_session_expiration_in_seconds" {
  default = "3600"
}

variable "waas_policy_waf_config_captchas_submit_label" {
  default = "Show me the Products!"
}

variable "waas_policy_waf_config_captchas_title" {
  default = "Quickly before you browse products..."
}

variable "waas_policy_waf_config_captchas_url" {
  default = "/product.html"
}

variable "waas_policy_waf_config_captchas_footer_text" {
  default = "Enter the letters and numbers as they are shown in the image above."
}

variable "waas_policy_waf_config_captchas_header_text" { 
  default = "Help us keep pet product shopping safe please."
}

