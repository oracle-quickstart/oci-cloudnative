output "Mushop" {
  value = "http://${data.oci_core_vnic.mushop_vnic.public_ip_address}"
}

output "autonomous_database_wallet_password" {
  value = "${random_string.autonomous_database_wallet_password.result}"
}

output "autonomous_database_wallet_uri" {
  value = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"
}


