# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_security_list" "mushop_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id
  display_name   = "mushop-main-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  egress_security_rules {
    protocol    = "6"
    destination = lookup(var.network_cidrs, "ALL-CIDR")
  }

  egress_security_rules {
    protocol         = "all"
    destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
  }

  egress_security_rules {
    protocol    = "all"
    destination = lookup(var.network_cidrs, "LB-VCN-CIDR")
  }

  ingress_security_rules {
    protocol = "all"
    source   = lookup(var.network_cidrs, "LB-VCN-CIDR")
  }

  ingress_security_rules {
    protocol = "6"
    source   = lookup(var.network_cidrs, "ALL-CIDR")

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = lookup(var.network_cidrs, "ALL-CIDR")

    tcp_options {
      max = "22"
      min = "22"
    }
  }
}

resource "oci_core_security_list" "mushop_lb_security_list" {
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  vcn_id         = var.create_secondary_vcn ? oci_core_virtual_network.mushop_lb_vcn[0].id : oci_core_virtual_network.mushop_main_vcn.id
  display_name   = "mushop-lb-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  }

  ingress_security_rules {
    protocol = "all"
    source   = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }
}
