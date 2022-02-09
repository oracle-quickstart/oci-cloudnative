# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

##**************************************************************************
##                            OCI KMS Vault
##**************************************************************************

### OCI Vault vault
resource "oci_kms_vault" "mushop_vault" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "${local.vault_display_name} - ${random_string.deploy_id.result}"
  vault_type     = local.vault_type[0]

  depends_on = [oci_identity_policy.kms_user_group_compartment_policies]

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}
### OCI Vault key
resource "oci_kms_key" "mushop_key" {
  compartment_id      = local.oke_compartment_ocid
  display_name        = "${local.vault_key_display_name} - ${random_string.deploy_id.result}"
  management_endpoint = oci_kms_vault.mushop_vault[0].management_endpoint

  key_shape {
    algorithm = local.vault_key_key_shape_algorithm
    length    = local.vault_key_key_shape_length
  }

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}

### Vault and Key definitions
locals {
  vault_display_name            = "MuShop Vault"
  vault_key_display_name        = "MuShop Key"
  vault_key_key_shape_algorithm = "AES"
  vault_key_key_shape_length    = 32
  vault_type                    = ["DEFAULT", "VIRTUAL_PRIVATE"]
}