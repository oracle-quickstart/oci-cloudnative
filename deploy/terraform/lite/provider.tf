# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0
# 
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  # user_ocid        = "${var.user_ocid}"
  # fingerprint      = "${var.fingerprint}"
  # private_key_path = "${var.private_key_path}"
  # region           = "${var.region}"
}
