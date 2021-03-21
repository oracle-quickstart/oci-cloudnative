# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "oke_mushop_dg" {
  name           = "mushop-oke-cluster-dg-${random_string.deploy_id.result}"
  description    = "MuShop Cluster Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"

  provider = oci.home_region
}
resource "oci_identity_policy" "mushop_oke_policies" {
  name           = "mushop-oke-cluster-policies-${random_string.deploy_id.result}"
  description    = "MuShop OKE Cluster Policies"
  compartment_id = var.compartment_ocid
  statements     = local.mushop_policies_statement

  depends_on = [oci_identity_dynamic_group.oke_mushop_dg]

  provider = oci.home_region
}

locals {
  mushop_policies_statement = concat(
    local.oci_grafana_metrics_policies_statement,
    local.oci_grafana_logs_policies_statement
  )
}

locals {
  oci_grafana_metrics_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to read metrics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to read compartments in compartment id ${var.compartment_ocid}"
  ]
  oci_grafana_logs_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to read log-groups in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to read log-content in compartment id ${var.compartment_ocid}"
  ]
  cluster_autoscaler_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to manage cluster-node-pools in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to manage instance-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to use subnets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to read virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to use vnics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_mushop_dg.name} to inspect compartments in compartment id ${var.compartment_ocid}"
  ]
}