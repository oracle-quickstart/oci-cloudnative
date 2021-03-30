# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "oke_vcn" {
  cidr_block     = lookup(var.network_cidrs, "VCN-CIDR")
  compartment_id = local.oke_compartment_ocid
  display_name   = "OKE MuShop VCN - ${random_string.deploy_id.result}"
  dns_label      = "oke${random_string.deploy_id.result}"

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_subnet" "oke_k8s_endpoint_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
  compartment_id             = local.oke_compartment_ocid
  display_name               = "oke-k8s-endpoint-subnet-${random_string.deploy_id.result}"
  dns_label                  = "okek8ssubnet${random_string.deploy_id.result}"
  vcn_id                     = oci_core_virtual_network.oke_vcn[0].id
  prohibit_public_ip_on_vnic = (var.cluster_endpoint_visibility == "Private") ? true : false
  route_table_id             = oci_core_route_table.oke_mushop_route_table[0].id
  dhcp_options_id            = oci_core_virtual_network.oke_vcn[0].default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.oke_mushop_security_list[0].id]

  count = var.create_new_oke_cluster ? 1 : 0
}
resource "oci_core_subnet" "oke_mushop_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
  compartment_id             = local.oke_compartment_ocid
  display_name               = "oke-mushop-subnet-${random_string.deploy_id.result}"
  dns_label                  = "okesubnet${random_string.deploy_id.result}"
  vcn_id                     = oci_core_virtual_network.oke_vcn[0].id
  prohibit_public_ip_on_vnic = (var.cluster_workers_visibility == "Private") ? true : false
  route_table_id             = oci_core_route_table.oke_mushop_route_table[0].id
  dhcp_options_id            = oci_core_virtual_network.oke_vcn[0].default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.oke_mushop_security_list[0].id]

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_subnet" "oke_mushop_lb_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "LB-SUBNET-REGIONAL-CIDR")
  compartment_id             = local.oke_compartment_ocid
  display_name               = "oke-mushop-lb-subnet-${random_string.deploy_id.result}"
  dns_label                  = "okelbsubnet${random_string.deploy_id.result}"
  vcn_id                     = oci_core_virtual_network.oke_vcn[0].id
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.oke_mushop_lb_route_table[0].id
  dhcp_options_id            = oci_core_virtual_network.oke_vcn[0].default_dhcp_options_id
  security_list_ids          = [oci_core_security_list.oke_mushop_lb_security_list[0].id]

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_route_table" "oke_mushop_route_table" {
  compartment_id = local.oke_compartment_ocid
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id
  display_name   = "oke-mushop-route-table-${random_string.deploy_id.result}"

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = (var.cluster_workers_visibility == "Private") ? oci_core_nat_gateway.oke_mushop_nat_gateway[0].id : oci_core_internet_gateway.oke_mushop_internet_gateway[0].id
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_route_table" "oke_mushop_lb_route_table" {
  compartment_id = local.oke_compartment_ocid
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id
  display_name   = "oke-mushop-lb-route-table-${random_string.deploy_id.result}"

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_mushop_internet_gateway[0].id
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_nat_gateway" "oke_mushop_nat_gateway" {
  block_traffic  = "false"
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-mushop-nat-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  count = var.create_new_oke_cluster ? ((var.cluster_workers_visibility == "Private") ? 1 : 0) : 0
}

resource "oci_core_internet_gateway" "oke_mushop_internet_gateway" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-mushop-internet-gateway-${random_string.deploy_id.result}"
  enabled        = true
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_service_gateway" "oke_mushop_service_gateway" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-mushop-service-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id
  services {
    service_id = lookup(data.oci_core_services.all_services.services[0], "id")
  }

  count = var.create_new_oke_cluster ? (var.mushop_mock_mode_all ? 0 : 1) : 0
}