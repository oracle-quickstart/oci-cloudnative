# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "oke_nodes_dg" {
  name           = "${lower(trimspace(var.app_name))}-oke-cluster-dg-${random_string.deploy_id.result}"
  description    = "${var.app_name} Cluster Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {instance.compartment.id = '${local.oke_compartment_ocid}'}"

  provider = oci.home_region

  count = var.create_dynamic_group_for_nodes_in_compartment ? 1 : 0
}
resource "oci_identity_policy" "oke_compartment_policies" {
  name           = "${lower(trimspace(var.app_name))}-oke-cluster-compartment-policies-${random_string.deploy_id.result}"
  description    = "${var.app_name} OKE Cluster Compartment Policies"
  compartment_id = local.oke_compartment_ocid
  statements     = local.oke_compartment_policies_statement

  depends_on = [oci_identity_dynamic_group.oke_nodes_dg]

  provider = oci.home_region

  count = var.create_compartment_policies ? 1 : 0
}

resource "oci_identity_policy" "oke_tenancy_policies" {
  name           = "${lower(trimspace(var.app_name))}-oke-cluster-tenancy-policies-${random_string.deploy_id.result}"
  description    = "${var.app_name} OKE Cluster Tenancy Policies"
  compartment_id = var.tenancy_ocid
  statements     = local.oke_tenancy_policies_statement

  depends_on = [oci_identity_dynamic_group.oke_nodes_dg]

  provider = oci.home_region

  count = var.create_tenancy_policies ? 1 : 0
}

locals {
  oke_compartment_policies_statement = concat(
    local.oci_grafana_logs_policies_statement
  )
  oke_tenancy_policies_statement = concat(
    local.oci_grafana_metrics_policies_statement
  )
}

locals {
  oke_nodes_dg = var.create_dynamic_group_for_nodes_in_compartment ? oci_identity_dynamic_group.oke_nodes_dg.0.name : "void"
  oci_grafana_metrics_policies_statement = [
    "Allow dynamic-group ${local.oke_nodes_dg} to read metrics in tenancy",
    "Allow dynamic-group ${local.oke_nodes_dg} to read compartments in tenancy"
  ]
  oci_grafana_logs_policies_statement = [
    "Allow dynamic-group ${local.oke_nodes_dg} to read log-groups in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to read log-content in compartment id ${local.oke_compartment_ocid}"
  ]
  cluster_autoscaler_policies_statement = [
    "Allow dynamic-group ${local.oke_nodes_dg} to manage cluster-node-pools in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to manage instance-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to use subnets in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to read virtual-network-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to use vnics in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.oke_nodes_dg} to inspect compartments in compartment id ${local.oke_compartment_ocid}"
  ]
}