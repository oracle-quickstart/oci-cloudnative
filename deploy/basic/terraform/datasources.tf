# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {

  compartment_id = "${var.tenancy_ocid}"

}


data "oci_objectstorage_namespace" "user_namespace" {

  compartment_id = "${var.compartment_ocid}"

}


resource "random_string" "autonomous_database_wallet_password" {

  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"

}

resource "random_id" "mushop_id" {
  byte_length = 2
}

data "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {

  autonomous_database_id = "${oci_database_autonomous_database.mushop_autonomous_database.id}"
  password               = "${random_string.autonomous_database_wallet_password.result}"
  base64_encode_content  = "false"

}
