# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
## OKE Cluster Details
variable "app_name" {
  default = "MuShop"
}
variable "cluster_name" {
  default = "MuShop-cluster"
}
variable "cluster_workers_visibility" {
  default = "Private"

  validation {
    condition     = var.cluster_workers_visibility == "Private" || var.cluster_workers_visibility == "Public"
    error_message = "Sorry, but cluster visibility can only be Private or Public."
  }
}

variable "cluster_endpoint_visibility" {
  default = "Public"

  validation {
    condition     = var.cluster_endpoint_visibility == "Private" || var.cluster_endpoint_visibility == "Public"
    error_message = "Sorry, but cluster endpoint visibility can only be Private or Public."
  }
}
variable "cluster_endpoint_config_is_public_ip_enabled" {
  default = true
} # Local?
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = false
}
variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  description = "If true: The pod security policy admission controller will use pod security policies to restrict the pods accepted into the cluster."
  default     = false
}
variable "create_new_oke_cluster" {
  default = true
}
variable "existent_oke_cluster_id" {
  default = ""
}
variable "create_new_compartment_for_oke" {
  default = false
}
variable "oke_compartment_description" {
  default = "Compartment for OKE, Nodes and Services"
}

## OKE Encryption details
variable "use_encryption" {
  default     = false
  description = "Uses standard block storage encryption or encrypt using customer-managed keys"
}
variable "create_new_encryption_key" {
  default = false
}
variable "encryption_key_id" {
  default = ""
}

## OKE Node Pool Details
variable "node_pool_name" {
  default = "pool1"
}
variable "k8s_version" {
  default = "Latest"
}
variable "num_pool_workers" {
  default = 1
}
variable "node_pool_shape" {
  default = "VM.Standard.E3.Flex" # "VM.Standard2.1"
}
variable "node_pool_node_shape_config_memory_in_gbs" {
  default = "16" # Only used if flex shape is selected
}
variable "node_pool_node_shape_config_ocpus" {
  default = "1" # Only used if flex shape is selected
}
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "7.9"
}
variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default = ""
}

# Network Details
## CIDRs
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                      = "10.20.0.0/16"
    SUBNET-REGIONAL-CIDR          = "10.20.10.0/24"
    LB-SUBNET-REGIONAL-CIDR       = "10.20.20.0/24"
    ENDPOINT-SUBNET-REGIONAL-CIDR = "10.20.0.0/28"
    ALL-CIDR                      = "0.0.0.0/0"
    PODS-CIDR                     = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR       = "10.96.0.0/16"
  }
}

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

# Create Dynamic Group and Policies
variable "create_dynamic_group_for_nodes_in_compartment" {
  default = false
}
variable "create_compartment_policies" {
  default = false
}
variable "create_tenancy_policies" {
  default = false
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
}