# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {
  default = "us-ashburn-1"
}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "public_ssh_key" {
  default = ""
}

# Cluster Details
variable "cluster_name" {
  default = "MuShop-cluster"
}
variable "cluster_visibility" {
  default = "Private"
}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = false
}
variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  default = false
}

# Node Pool Details
variable "node_pool_name" {
  default = "pool1"
}

variable "k8s_version" {
  default = "v1.15.7"
}
variable "num_pool_workers" {
  default = 2
}
variable "node_pool_shape" {
  default = "VM.Standard.E2.1"
}
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "7.7"
}

# Network Details
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                = "10.20.0.0/16"
    SUBNET-REGIONAL-CIDR    = "10.20.10.0/24"
    LB-SUBNET-REGIONAL-CIDR = "10.20.20.0/24"
    ALL-CIDR                = "0.0.0.0/0"
  }
}
