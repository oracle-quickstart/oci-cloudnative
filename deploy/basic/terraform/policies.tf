# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
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
  statements = (var.use_encryption_from_oci_vault ?
    (var.create_vault_policies_for_group ? (
      concat(local.allow_object_storage_lifecycle_statement, local.allow_object_storage_service_keys_statements, local.allow_group_manage_vault_keys_statements)
      ) : concat(local.allow_object_storage_lifecycle_statement, local.allow_object_storage_service_keys_statements)
  ) : local.allow_object_storage_lifecycle_statement)
  freeform_tags = local.common_tags
}

locals {
  allow_object_storage_lifecycle_statement = ["Allow service objectstorage-${var.region} to manage object-family in compartment id ${var.compartment_ocid}"]
  allow_object_storage_service_keys_statements = [
    "Allow service objectstorage-${var.region} to use vaults in compartment id ${var.compartment_ocid}",
    "Allow service objectstorage-${var.region} to use keys in compartment id ${var.compartment_ocid}"
  ]
  allow_group_manage_vault_keys_statements = [
    "Allow group ${var.user_admin_group_for_vault_policy} to manage vaults in compartment id ${var.compartment_ocid}",
    "Allow group ${var.user_admin_group_for_vault_policy} to manage keys in compartment id ${var.compartment_ocid}"
  ]
}
