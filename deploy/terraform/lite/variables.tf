# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
# 
variable "tenancy_ocid" {}

variable "region" {}

variable "compartment_ocid" {}
variable "database_name" {
  default = "mushop"
}
variable "ssh_public_key" {
 default = ""
}
