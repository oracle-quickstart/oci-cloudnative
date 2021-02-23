# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "mushop_main_vcn" {
  cidr_block     = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  compartment_id = var.compartment_ocid
  display_name   = "mushop-main-${random_string.deploy_id.result}"
  dns_label      = "mushopmain${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags
}

resource "oci_core_virtual_network" "mushop_lb_vcn" {
  cidr_block     = lookup(var.network_cidrs, "LB-VCN-CIDR")
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  display_name   = "mushop-lb-${random_string.deploy_id.result}"
  dns_label      = "mushoplb${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  count = var.create_secondary_vcn ? 1 : 0
}

resource "oci_core_subnet" "mushop_main_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "MAIN-SUBNET-REGIONAL-CIDR")
  display_name               = "mushop-main-${random_string.deploy_id.result}"
  dns_label                  = "mushopmain${random_string.deploy_id.result}"
  security_list_ids          = [oci_core_security_list.mushop_security_list.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.mushop_main_vcn.id
  route_table_id             = oci_core_route_table.mushop_main_route_table.id
  dhcp_options_id            = oci_core_virtual_network.mushop_main_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = (var.instance_visibility == "Private") ? true : false
  freeform_tags              = local.common_tags
}

resource "oci_core_subnet" "mushop_lb_subnet" {
  cidr_block                 = lookup(var.network_cidrs, (var.create_secondary_vcn ? "LB-SUBNET-REGIONAL-CIDR" : "MAIN-LB-SUBNET-REGIONAL-CIDR"))
  display_name               = "mushop-lb-${random_string.deploy_id.result}"
  dns_label                  = "mushoplb${random_string.deploy_id.result}"
  security_list_ids          = [oci_core_security_list.mushop_lb_security_list.id]
  compartment_id             = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  vcn_id                     = var.create_secondary_vcn ? oci_core_virtual_network.mushop_lb_vcn[0].id : oci_core_virtual_network.mushop_main_vcn.id
  route_table_id             = oci_core_route_table.mushop_lb_route_table.id
  dhcp_options_id            = var.create_secondary_vcn ? oci_core_virtual_network.mushop_lb_vcn[0].default_dhcp_options_id : oci_core_virtual_network.mushop_main_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.common_tags
}

resource "oci_core_route_table" "mushop_main_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id
  display_name   = "mushop-main-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  dynamic "route_rules" {
    for_each = (var.instance_visibility == "Private") ? [1] : []
    content {
      destination       = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.mushop_service_gateway.id
    }
  }

  dynamic "route_rules" {
    for_each = (var.instance_visibility == "Private") ? [] : [1]
    content {
      destination       = lookup(var.network_cidrs, "ALL-CIDR")
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.mushop_internet_gateway.id
    }
  }

  dynamic "route_rules" {
    for_each = var.create_secondary_vcn ? [1] : []
    content {
      destination       = lookup(var.network_cidrs, "LB-VCN-CIDR")
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_local_peering_gateway.main_local_peering_gateway[0].id
    }
  }
}

resource "oci_core_route_table" "mushop_lb_route_table" {
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  vcn_id         = var.create_secondary_vcn ? oci_core_virtual_network.mushop_lb_vcn[0].id : oci_core_virtual_network.mushop_main_vcn.id
  display_name   = "mushop-lb-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mushop_internet_gateway.id
  }

  dynamic "route_rules" {
    for_each = var.create_secondary_vcn ? [1] : []
    content {
      destination       = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_local_peering_gateway.lb_local_peering_gateway[0].id
    }
  }
}

resource "oci_core_nat_gateway" "mushop_nat_gateway" {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name   = "mushop-nat-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id
  freeform_tags  = local.common_tags

  count = var.use_only_always_free_elegible_resources ? 0 : ((var.instance_visibility == "Private") ? 0 : 0)
}

resource "oci_core_internet_gateway" "mushop_internet_gateway" {
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  display_name   = "mushop-internet-gateway-${random_string.deploy_id.result}"
  vcn_id         = var.create_secondary_vcn ? oci_core_virtual_network.mushop_lb_vcn[0].id : oci_core_virtual_network.mushop_main_vcn.id
  freeform_tags  = local.common_tags
}

resource "oci_core_service_gateway" "mushop_service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "mushop-service-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id
  services {
    service_id = lookup(data.oci_core_services.all_services.services[0], "id")
  }

  count = var.use_only_always_free_elegible_resources ? 0 : 1
}

resource "oci_core_local_peering_gateway" "main_local_peering_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id
  display_name   = "localPeeringGateway - main"
  peer_id        = oci_core_local_peering_gateway.lb_local_peering_gateway[0].id

  count = var.create_secondary_vcn ? 1 : 0
}

resource "oci_core_local_peering_gateway" "lb_local_peering_gateway" {
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mushop_lb_vcn[0].id
  display_name   = "localPeeringGateway - lb"

  count = var.create_secondary_vcn ? 1 : 0
}

resource "oci_core_network_security_group" "atp_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "atp_nsg"
  freeform_tags  = local.common_tags
  vcn_id         = oci_core_virtual_network.mushop_main_vcn.id

  count = (var.autonomous_database_visibility == "Private") ? 1 : 0
}
resource "oci_core_network_security_group_security_rule" "atp_nsg_rule_1" {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.atp_nsg[0].id
  protocol                  = "all"
  source                    = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  source_type               = "CIDR_BLOCK"

  count = (var.autonomous_database_visibility == "Private") ? 1 : 0
}
resource "oci_core_network_security_group_security_rule" "atp_nsg_rule_2" {
  destination               = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  network_security_group_id = oci_core_network_security_group.atp_nsg[0].id
  protocol                  = "all"
  source_type               = ""

  count = (var.autonomous_database_visibility == "Private") ? 1 : 0
}