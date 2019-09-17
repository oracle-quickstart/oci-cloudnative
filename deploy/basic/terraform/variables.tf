# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
variable "tenancy_ocid" {}
variable "region" {}

variable "compartment_ocid" {}

variable "availability_domain" {
  default = 1
}

variable "num_nodes" {
  default = 1
}

variable "database_name" {
  default = "mushop"
}
variable "ssh_public_key" {
  default = ""
}
