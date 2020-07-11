# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# creates an ATP database
resource "oci_database_autonomous_database" "mushop_autonomous_database" {
  admin_password           = random_string.autonomous_database_wallet_password.result
  compartment_id           = var.compartment_ocid
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  db_name                  = var.autonomous_database_name
  db_version               = var.autonomous_database_db_version
  display_name             = "${var.autonomous_database_name}${random_id.mushop_id.dec}"
  freeform_tags            = local.common_tags
  is_free_tier             = var.autonomous_database_is_free_tier
  license_model            = var.autonomous_database_license_model
}
