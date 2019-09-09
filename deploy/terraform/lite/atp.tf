# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
# 

# creates an ATP database
resource "oci_database_autonomous_database" "mushop_autonomous_database" {
  #Required
  admin_password           = "${random_string.autonomous_database_wallet_password.result}"
  compartment_id           = "${var.compartment_ocid}"
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1
  db_name                  = "${var.database_name}${random_id.mushop_id.dec}"

  #Optional

  db_workload                                    = "OLTP"
  display_name                                   = "${var.database_name}${random_id.mushop_id.dec}"
  is_auto_scaling_enabled                        = false
  is_dedicated                                   = false
  is_preview_version_with_service_terms_accepted = false

}
