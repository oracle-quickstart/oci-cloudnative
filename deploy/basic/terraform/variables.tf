# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

variable "tenancy_ocid" {}
variable "region" {}

variable "compartment_ocid" {}

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
  default = "VM.Standard.E2.1.Micro"
}
variable "lb_shape" {
  default = "10Mbps-Micro"
}
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "7.8"
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
  default = true
}

