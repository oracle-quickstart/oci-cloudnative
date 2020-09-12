# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create lifecycle policy to delete temp files
resource "oci_objectstorage_object_lifecycle_policy" "mushop_deploy_assets_lifecycle_policy" {
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  bucket    = oci_objectstorage_bucket.mushop.name

  rules {
    action      = "DELETE"
    is_enabled  = "true"
    name        = "mushop-delete-deploy-assets-rule"
    time_amount = "1"
    time_unit   = "DAYS"
  }
  depends_on = [oci_identity_policy.mushop_basic_policies, oci_objectstorage_object.mushop_wallet]
}

# Create policies for MuShop based on the features
resource "oci_identity_policy" "mushop_basic_policies" {
  name           = "mushop-basic-policies-${random_string.deploy_id.result}"
  description    = "Policies created by terraform for MuShop Basic"
  compartment_id = var.compartment_ocid
  statements     = local.mushop_basic_policies_statement
  freeform_tags  = local.common_tags

  provider = oci.home_region
}

locals {
  mushop_basic_policies_statement = concat(
    local.allow_object_storage_lifecycle_statement,
    var.use_encryption_from_oci_vault ? local.allow_object_storage_service_keys_statements : [],
    var.use_encryption_from_oci_vault ? local.allow_media_object_storage_service_keys_statements : [],
    var.create_vault_policies_for_group ? local.allow_group_manage_vault_keys_statements : [],
    local.allow_group_manage_local_peering_statements
  )
}

locals {
  allow_object_storage_lifecycle_statement = ["Allow service objectstorage-${var.region} to manage object-family in compartment id ${var.compartment_ocid}"]
  allow_object_storage_service_keys_statements = [
    "Allow service blockstorage, objectstorage-${var.region} to use vaults in compartment id ${var.compartment_ocid}",
    "Allow service blockstorage, objectstorage-${var.region} to use keys in compartment id ${var.compartment_ocid}"
  ]
  allow_media_object_storage_service_keys_statements = [
    "Allow service blockstorage, objectstorage-${var.region} to use vaults in compartment id ${(var.object_storage_mushop_media_compartment_ocid != "") ? var.object_storage_mushop_media_compartment_ocid : var.compartment_ocid}",
    "Allow service blockstorage, objectstorage-${var.region} to use keys in compartment id ${(var.object_storage_mushop_media_compartment_ocid != "") ? var.object_storage_mushop_media_compartment_ocid : var.compartment_ocid}"
  ]
  allow_group_manage_vault_keys_statements = [
    "Allow group ${var.user_admin_group_for_vault_policy} to manage vaults in compartment id ${var.compartment_ocid}",
    "Allow group ${var.user_admin_group_for_vault_policy} to manage keys in compartment id ${var.compartment_ocid}"
  ]
  allow_group_manage_local_peering_statements = [
    "Allow group ${var.user_admin_group_for_vault_policy} to manage local-peering-gateways in compartment id ${var.compartment_ocid}",
    "Allow group ${var.user_admin_group_for_vault_policy} to manage local-peering-gateways in compartment id ${(var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid}"
  ]
}
