# LICENSE UPL 1.0
#
# Copyright (c) 1982-2019 Oracle and/or its affiliates. All rights reserved.
# 

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {

  compartment_id = "${var.tenancy_ocid}"

}

data "oci_core_vnic_attachments" "mushop_vnics" {

  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[local.availability_domain - 1], "name")}"
  instance_id         = "${oci_core_instance.app-instance.id}"

}

data "oci_core_vnic" "mushop_vnic" {

  vnic_id = "${lookup(data.oci_core_vnic_attachments.mushop_vnics.vnic_attachments[0], "vnic_id")}"

}

data "oci_objectstorage_namespace" "user_namespace" {

    compartment_id = "${var.compartment_ocid}"

}


resource "random_string" "autonomous_database_wallet_password" {

  length      = 16
  special     = true
  min_upper   = 3
  min_lower   = 3
  min_numeric = 3
  min_special = 3
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

resource "local_file" "autonomous_database_wallet_file" {

  content = "${data.oci_database_autonomous_database_wallet.autonomous_database_wallet.content}"
  filename       = "${path.module}/autonomous_database_wallet.zip"

}
