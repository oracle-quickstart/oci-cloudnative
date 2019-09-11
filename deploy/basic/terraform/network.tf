# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
resource "oci_core_virtual_network" "mushopVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushop-${random_id.mushop_id.dec}"
  dns_label      = "mushop${random_id.mushop_id.dec}"
  freeform_tags  = "${local.common_tags}"
}

resource "oci_core_subnet" "mushopSubnet" {
  cidr_block                 = "10.1.20.0/24"
  prohibit_public_ip_on_vnic = true
  display_name               = "mushop-${random_id.mushop_id.dec}"
  dns_label                  = "mushop${random_id.mushop_id.dec}"
  security_list_ids          = ["${oci_core_security_list.mushopSecurityList.id}"]
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${oci_core_virtual_network.mushopVCN.id}"
  route_table_id             = "${oci_core_route_table.mushopRT.id}"
  dhcp_options_id            = "${oci_core_virtual_network.mushopVCN.default_dhcp_options_id}"
  freeform_tags              = "${local.common_tags}"
}

resource "oci_core_subnet" "mushopLBSubnet" {
  cidr_block        = "10.1.21.0/24"
  display_name      = "mushop-lb-${random_id.mushop_id.dec}"
  dns_label         = "mushoplb${random_id.mushop_id.dec}"
  security_list_ids = ["${oci_core_security_list.mushopLBSecurityList.id}"]
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.mushopVCN.id}"
  route_table_id    = "${oci_core_route_table.mushopLBRT.id}"
  dhcp_options_id   = "${oci_core_virtual_network.mushopVCN.default_dhcp_options_id}"
  freeform_tags     = "${local.common_tags}"
}


resource "oci_core_nat_gateway" "mushopNat" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushop-nat-${random_id.mushop_id.dec}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  freeform_tags  = "${local.common_tags}"
}

resource "oci_core_internet_gateway" "mushopIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushop-IG-${random_id.mushop_id.dec}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  freeform_tags  = "${local.common_tags}"
}

resource "oci_core_route_table" "mushopLBRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushop-lb-${random_id.mushop_id.dec}"
  freeform_tags  = "${local.common_tags}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.mushopIG.id}"
  }
}

resource "oci_core_route_table" "mushopRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushop-node-${random_id.mushop_id.dec}"
  freeform_tags  = "${local.common_tags}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_nat_gateway.mushopNat.id}"
  }

  route_rules {
    destination       = "${lookup(data.oci_core_services.all_services.services[0], "cidr_block")}"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = "${oci_core_service_gateway.mushopSGW.id}"
  }
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


resource "oci_core_service_gateway" "mushopSGW" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushop-sgw-${random_id.mushop_id.dec}"

  services {
    service_id = "${lookup(data.oci_core_services.all_services.services[0], "id")}"
  }
}