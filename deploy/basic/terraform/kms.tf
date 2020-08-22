# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Creates OCI Vault vault
resource "oci_kms_vault" "mushop_vault" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vault_display_name} - ${random_string.deploy_id.result}"
  vault_type     = var.vault_type[0]
  freeform_tags  = local.common_tags

  count      = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
  depends_on = [oci_identity_policy.mushop_basic_policies]
}

# Creates OCI Vault key
resource "oci_kms_key" "mushop_key" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.vault_key_display_name} - ${random_string.deploy_id.result}"
  management_endpoint = oci_kms_vault.mushop_vault[0].management_endpoint

  key_shape {
    algorithm = var.vault_key_key_shape_algorithm
    length    = var.vault_key_key_shape_length
  }
  freeform_tags = local.common_tags

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}
