data "template_file" "mushop" {
  template = "${file("./scripts/node.sh")}"
}

resource "oci_core_instance" "app-instance" {
  count               = "${var.NumInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "app-instance-${count.index}"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.mushopSubnet.id}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "app-instance-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.images[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(data.template_file.mushop.rendered)}"
    db_name             = "${oci_database_autonomous_database.mushop_autonomous_database.db_name}"
    atp_pw              = "${random_string.autonomous_database_wallet_password.result}"
    catalogue_sql_par   = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.catalogue_sql_script_preauth.access_uri}"
    apache_conf_par     = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.apache_conf_preauth.access_uri}"
    entrypoint_par      = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.entrypoint_preauth.access_uri}"
    mushop_app_par      = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_lite_preauth.access_uri}"
    wallet_par          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"

  }
  
}
