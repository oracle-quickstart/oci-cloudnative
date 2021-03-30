# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# MuShop
## Ingress/LoadBalancer
variable "ingress_load_balancer_shape" {
  default = "100Mbps"
}

## Features
variable "mushop_mock_mode_all" {
  default = false
}

## Common Services (MuShop Utilities)
variable "grafana_enabled" {
  default = true
}
variable "prometheus_enabled" {
  default = true
}
variable "metrics_server_enabled" {
  default = true
}
variable "catalog_enabled" {
  default = true
}
variable "ingress_nginx_enabled" {
  default = true
}
variable "cert_manager_enabled" {
  default = true
}

## Secrets
variable "db_admin_name" {
  default = "oadb-admin"
}
variable "db_connection_name" {
  default = "oadb-connection"
}
variable "db_wallet_name" {
  default = "oadb-wallet"
}
variable "oos_bucket_name" {
  default = "oos-bucket"
}

# OCI Services
## Autonomous Database
variable "autonomous_database_cpu_core_count" {
  default = 1
}

variable "autonomous_database_data_storage_size_in_tbs" {
  default = 1
}

variable "autonomous_database_data_safe_status" {
  default = "NOT_REGISTERED" # REGISTERED || NOT_REGISTERED

  validation {
    condition     = var.autonomous_database_data_safe_status == "REGISTERED" || var.autonomous_database_data_safe_status == "NOT_REGISTERED"
    error_message = "Sorry, but database license model can only be REGISTERED or NOT_REGISTERED."
  }
}

variable "autonomous_database_db_version" {
  default = "19c"
}

variable "autonomous_database_license_model" {
  default = "BRING_YOUR_OWN_LICENSE" # LICENSE_INCLUDED || BRING_YOUR_OWN_LICENSE

  validation {
    condition     = var.autonomous_database_license_model == "BRING_YOUR_OWN_LICENSE" || var.autonomous_database_license_model == "LICENSE_INCLUDED"
    error_message = "Sorry, but database license model can only be BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED."
  }
}

variable "autonomous_database_is_auto_scaling_enabled" {
  default = false
}

variable "autonomous_database_is_free_tier" {
  default = false
}
variable "autonomous_database_visibility" {
  default = "Public"

  validation {
    condition     = var.autonomous_database_visibility == "Private" || var.autonomous_database_visibility == "Public"
    error_message = "Sorry, but database visibility can only be Private or Public."
  }
}
variable "autonomous_database_wallet_generate_type" {
  default = "SINGLE"
}