provider "acme" {
  server_url = var.acme_server_url
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  # Conditional
  count = var.enable_acme_certificate ? 1 : 0

  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = var.acme_email
}

resource "acme_certificate" "certificate" {
  # Conditional
  count = var.enable_acme_certificate ? 1 : 0

  account_key_pem           = "${acme_registration.reg[0].account_key_pem}"
  common_name               = local.dns_waf_domain
  subject_alternative_names = [local.dns_lb_domain]

  dns_challenge {
    provider = "oraclecloud"
    config = {
      OCI_PRIVKEY_FILE=var.private_key_path
      OCI_TENANCY_OCID=var.tenancy_ocid
      OCI_USER_OCID=var.user_ocid
      OCI_PUBKEY_FINGERPRINT=var.fingerprint
      OCI_REGION=var.region
      OCI_COMPARTMENT_OCID=var.lb_compartment_ocid
    }
  }
}

output "public_certificate_common_name" {
  value = var.enable_acme_certificate ? "${acme_certificate.certificate[0].certificate_domain}" : null
}
output "private_key_pem" {
  value = var.enable_acme_certificate ? "${acme_certificate.certificate[0].private_key_pem}" : null
}
output "certificate_pem" {
  value = var.enable_acme_certificate ? "${acme_certificate.certificate[0].certificate_pem}${acme_certificate.certificate[0].issuer_pem}" : null
}
