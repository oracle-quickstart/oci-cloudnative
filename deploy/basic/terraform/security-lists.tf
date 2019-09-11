# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
resource "oci_core_security_list" "mushopSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushop-node-${random_id.mushop_id.dec}"
  freeform_tags  = "${local.common_tags}"

  egress_security_rules = [
    {
      protocol    = "6"
      destination = "0.0.0.0/0"
    }
  ]

  ingress_security_rules {
    protocol = "6"
    source   = "${oci_core_subnet.mushopLBSubnet.cidr_block}"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "${oci_core_subnet.mushopLBSubnet.cidr_block}"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}

resource "oci_core_security_list" "mushopLBSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushop-lb-${random_id.mushop_id.dec}"
  freeform_tags  = "${local.common_tags}"

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
      max = "80"
      min = "80"
    }
  }
}
