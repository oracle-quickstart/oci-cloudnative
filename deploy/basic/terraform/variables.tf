# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
variable "tenancy_ocid" {}
variable "region" {}

variable "compartment_ocid" {}

# variable "instance_shape" {
#   default = "VM.Standard.E2.1.Micro"
# }

variable "availability_domain" {
  default = 1
}

variable "num_nodes" {
  default = 1
}

# variable "lb_shape" {
#   default = "10Mbps-Micro"
# }

variable "database_name" {
  default = "mushop"
}
variable "ssh_public_key" {
  default = ""
}
