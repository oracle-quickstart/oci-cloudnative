# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "oke_nodes_dg" {
  name           = "${lower(trimspace(var.app_name))}-oke-cluster-dg-${random_string.deploy_id.result}"
  description    = "${var.app_name} Cluster Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {instance.compartment.id = '${local.oke_compartment_ocid}'}"

  provider = oci.home_region

  count          = var.create_dynamic_group_for_nodes_in_compartment ? 1 : 0
}
resource "oci_identity_policy" "oke_compartment_policies" {
  name           = "${lower(trimspace(var.app_name))}-oke-cluster-policies-${random_string.deploy_id.result}"
  description    = "${var.app_name} OKE Cluster Policies"
  compartment_id = local.oke_compartment_ocid
  statements     = local.oke_compartment_policies_statement

  depends_on = [oci_identity_dynamic_group.oke_nodes_dg]

  provider = oci.home_region

  count          = var.create_compartment_policies ? 1 : 0
}

locals {
  oke_compartment_policies_statement = concat(
    local.oci_grafana_metrics_policies_statement,
    local.oci_grafana_logs_policies_statement
  )
}

locals {
  oci_grafana_metrics_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to read metrics in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to read compartments in compartment id ${local.oke_compartment_ocid}"
  ]
  oci_grafana_logs_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to read log-groups in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to read log-content in compartment id ${local.oke_compartment_ocid}"
  ]
  cluster_autoscaler_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to manage cluster-node-pools in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to manage instance-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to use subnets in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to read virtual-network-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to use vnics in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_nodes_dg.0.name} to inspect compartments in compartment id ${local.oke_compartment_ocid}"
  ]
}