# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# MuShop
## Ingress/LoadBalancer
variable "ingress_nginx_enabled" {
  default     = true
  description = "Enable Ingress Nginx for Kubernetes Services (This option provision a Load Balancer)"
}
variable "ingress_load_balancer_shape" {
  default     = "flexible" # Flexible, 10Mbps, 100Mbps, 400Mbps or 8000Mps
  description = "Shape that will be included on the Ingress annotation for the OCI Load Balancer creation"
}
variable "ingress_load_balancer_shape_flex_min" {
  default     = "10"
  description = "Enter the minimum size of the flexible shape."
}
variable "ingress_load_balancer_shape_flex_max" {
  default     = "100"
  description = "Enter the maximum size of the flexible shape (Should be bigger than minimum size). The maximum service limit is set by your tenancy limits."
}
variable "ingress_hosts" {
  default     = ""
  description = "Enter a valid full qualified domain name (FQDN). You will need to map the domain name to the EXTERNAL-IP address on your DNS provider (DNS Registry type - A). If you have multiple domain names, include separated by comma. e.g.: mushop.example.com,catshop.com"
}
variable "cert_manager_enabled" {
  default     = true
  description = "Enable x509 Certificate Management"
}
variable "ingress_tls" {
  default     = false
  description = "If enabled, will generate SSL certificates to enable HTTPS for the ingress using the Certificate Issuer"
}
variable "ingress_cluster_issuer" {
  default     = "letsencrypt-prod"
  description = "Certificate issuer type. Currently supports the free Let's Encrypt and Self-Signed. Only *letsencrypt-prod* generates valid certificates"
}
variable "ingress_email_issuer" {
  default     = "no-reply@mushop.ateam.cloud"
  description = "You must replace this email address with your own. The certificate provider will use this to contact you about expiring certificates, and issues related to your account."
}

## Features
variable "mushop_mock_mode_all" {
  default     = false
  description = "If enabled, will not provision ATP Database, Object Storage, or Streaming. The services will run in mock mode and will connect to an in-memory database, and the data will not persist"
}
variable "create_oci_service_user" {
  default     = false
  description = "Creates OCI Service User. Service user is needed for Email Delivery (Newsletter feature) and Stream services."
}
variable "newsletter_subscription_enabled" {
  default     = false
  description = "(Currently only supported on the US-Ashburn-1 region) Enables newsletter subscription feature. Deploys API Gateway, Newsletter Function and uses Email Sender service"
}
variable "newsletter_email_sender" {
  default     = "no-reply@mushop.ateam.cloud"
  description = "Email sender suffix for Newsletter Subscription. The deployment id will added as email suffix. e.g.: no-reply+xyz1@mushop.ateam.cloud"
}
variable "newsletter_subscription_function_image" {
  default     = "iad.ocir.io/ociateam/mushop/newsletter-subscription"
  description = "Container Image for the Newsletter Subscription Function"
}
variable "newsletter_subscription_function_image_version" {
  default     = "0.1.0"
  description = "Container Image Version for the Newsletter Subscription Function"
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
  description = "Enable Metrics Server for Metrics, HPA, VPA and Cluster Autoscaler"
}
variable "catalog_enabled" {
  default     = false
  description = "Enable Service Catalog to use with OCI Service Broker"
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

## Oracle Digital Assistant
variable "oda_enabled" {
  default     = false
  description = "Enables the Oracle Digital Assistant as widget on the storefront. (chatbot balloon will appear on the MuShop UI) \nNOTE: This stack currently does not provision ODA, you need to bring your ODA instance and bot details."
}
variable "oda_uri" {
  default     = ""
  description = "Oracle Digital Assistant server URI. Do not include https: and slashes. e.g.: oda-xxxxxxx-x.data..digitalassistant.oci.oraclecloud.com"
}
variable "oda_channel_id" {
  default     = ""
  description = "Oracle Digital Assistant Channel Id to be used with MuShop."
}
variable "oda_channel_secret" {
  default     = ""
  description = "Oracle Digital Assistant channel secret. NOTE: Only necessary if Client Auth is enabled"
}
variable "oda_user_init_message" {
  default     = ""
  description = "Oracle Digital Assistant initial hidden user message. Makes the Digital Assistant proactive. e.g.: Trending Today"
}