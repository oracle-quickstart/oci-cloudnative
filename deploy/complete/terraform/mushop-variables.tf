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
