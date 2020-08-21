# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "mushopVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "mushop-${random_string.deploy_id.result}"
  dns_label      = "mushop${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags
}



resource "oci_core_subnet" "mushopLBSubnet" {
  cidr_block        = "10.1.21.0/24"
  display_name      = "mushop-lb-${random_string.deploy_id.result}"
  dns_label         = "mushoplb${random_string.deploy_id.result}"
  security_list_ids = [oci_core_security_list.mushopLBSecurityList.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.mushopVCN.id
  route_table_id    = oci_core_route_table.mushopLBRT.id
  dhcp_options_id   = oci_core_virtual_network.mushopVCN.default_dhcp_options_id
  freeform_tags     = local.common_tags
}



resource "oci_core_internet_gateway" "mushopIG" {
  compartment_id = var.compartment_ocid
  display_name   = "mushop-IG-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.mushopVCN.id
  freeform_tags  = local.common_tags
}

resource "oci_core_route_table" "mushopLBRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mushopVCN.id
  display_name   = "mushop-lb-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mushopIG.id
  }
}

