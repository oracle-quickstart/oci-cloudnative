# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "cluster_autoscaler_dg" {
  name           = "mushop-cluster-autoscaler-dg-${random_string.deploy_id.result}"
  description    = "MuShop Cluster Autoscaler Dynamic Group"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
  
  provider = oci.home_region
}
resource "oci_identity_policy" "cluster_autoscaler_policies" {
  name           = "mushop-cluster-autoscaler-policies-${random_string.deploy_id.result}"
  description    = "MuShop Cluster Autoscaler Policies"
  compartment_id = var.compartment_ocid
  statements     = local.cluster_autoscaler_policies_statement

  depends_on = [oci_identity_dynamic_group.cluster_autoscaler_dg]
  
  provider = oci.home_region
}

locals {

  cluster_autoscaler_policies_statement = [
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to manage cluster-node-pools in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to manage instance-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to use subnets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to read virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to use vnics in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cluster_autoscaler_dg.name} to inspect compartments in compartment id ${var.compartment_ocid}"
  ]
}