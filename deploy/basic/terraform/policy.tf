# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create policy to allow use lifecycle
resource "oci_identity_policy" "mushop_allow_object_storage_lifecycle" {
  name           = "mushop-object-family-${random_id.mushop_id.dec}"
  description    = "policy created by terraform for MuShop Basic"
  compartment_id = "${var.tenancy_ocid}"
  statements     = ["Allow service objectstorage-${var.region} to manage object-family in tenancy"]
  freeform_tags  = "${local.common_tags}"
}
