# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "oke-mushop_vcn" {
  cidr_block     = lookup(var.network_cidrs, "VCN-CIDR")
  compartment_id = var.compartment_ocid
  display_name   = "OKE MuShop VCN - ${random_string.deploy_id.result}"
  dns_label      = "oke${random_string.deploy_id.result}"
}

resource "oci_core_subnet" "oke-mushop_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
  compartment_id             = var.compartment_ocid
  display_name               = "oke-mushop_subnet-${random_string.deploy_id.result}"
  dns_label                  = "okesubnet${random_string.deploy_id.result}"
  vcn_id                     = oci_core_virtual_network.oke-mushop_vcn.id
  prohibit_public_ip_on_vnic = (var.cluster_visibility == "Private") ? true : false
  route_table_id             = oci_core_route_table.oke-mushop_route_table.id
  dhcp_options_id            = oci_core_virtual_network.oke-mushop_vcn.default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.oke-mushop_security_list.id]
}

resource "oci_core_subnet" "oke-mushop_lb_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "LB-SUBNET-REGIONAL-CIDR")
  compartment_id             = var.compartment_ocid
  display_name               = "oke-mushop_lb_subnet-${random_string.deploy_id.result}"
  dns_label                  = "okelbsubnet${random_string.deploy_id.result}"
  vcn_id                     = oci_core_virtual_network.oke-mushop_vcn.id
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.oke-mushop_lb_route_table.id
  dhcp_options_id            = oci_core_virtual_network.oke-mushop_vcn.default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.oke-mushop_lb_security_list.id]
}

resource "oci_core_route_table" "oke-mushop_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.oke-mushop_vcn.id
  display_name   = "oke-mushop_route_table-${random_string.deploy_id.result}"

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = (var.cluster_visibility == "Private") ? oci_core_nat_gateway.oke-mushop_nat_gateway[0].id : oci_core_internet_gateway.oke-mushop_internet_gateway.id
  }
}

resource "oci_core_route_table" "oke-mushop_lb_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.oke-mushop_vcn.id
  display_name   = "oke-mushop_route_table-${random_string.deploy_id.result}"

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke-mushop_internet_gateway.id
  }
}

resource "oci_core_nat_gateway" "oke-mushop_nat_gateway" {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name   = "oke-mushop_nat_gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke-mushop_vcn.id

  count = (var.cluster_visibility == "Private") ? 1 : 0
}

resource "oci_core_internet_gateway" "oke-mushop_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-mushop_internet_gateway-${random_string.deploy_id.result}"
  enabled        = true
  vcn_id         = oci_core_virtual_network.oke-mushop_vcn.id
}

resource "oci_core_service_gateway" "oke_mushop_service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-mushop-service-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke-mushop_vcn.id
  services {
        service_id = lookup(data.oci_core_services.test_services.services[0], "id")
  }

  count = var.mushop_mock_mode_all ? 0 : 1
}