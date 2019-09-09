# LICENSE UPL 1.0
#
# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
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
