# LICENSE UPL 1.0
#
# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# 
resource "oci_core_security_list" "mushopSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushopSecurityList"

  egress_security_rules = [
    {
      protocol    = "6"
      destination = "0.0.0.0/0"
    }
  ]

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}
