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
  default     = false
  description = "If enabled, will not provision ATP Database, Object Storage, or Streaming. The services will run in mock mode and will connect to an in-memory database, and the data will not persist"
}

## Common Services (MuShop Utilities)
variable "grafana_enabled" {
  default     = true
  description = "Enable Grafana Dashboards. Includes example dashboards and Prometheus, OCI Logging and OCI Metrics datasources"
}
variable "prometheus_enabled" {
  default     = true
  description = "Enable Prometheus"
}
variable "metrics_server_enabled" {
  default     = true
  description = "Enable Metrics Server for Metrics, HPA, VPA and Cluster Auto Scaling"
}
variable "catalog_enabled" {
  default     = false
  description = "Enable Service Catalog to use with OCI Service Broker"
}
variable "ingress_nginx_enabled" {
  default     = true
  description = "Enable Ingress Nginx for Services (Provision a Load Balancer)"
}
variable "cert_manager_enabled" {
  default     = true
  description = "Enable x509 Certificate Management"
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