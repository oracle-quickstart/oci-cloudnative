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
  common_name               = "store.mushop.agregory.page"
  subject_alternative_names = ["mushop-internal.mushop.agregory.page"]

  dns_challenge {
    provider = "oraclecloud"
    config = {
      OCI_PRIVKEY_FILE="/home/andrew_gre/.oci/oci_api_key.pem"
      OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaa5arrzhx6wibc7iotaztfkt5bofbrfkw4x56kaplt36tat63lexgq"
      OCI_USER_OCID="ocid1.user.oc1..aaaaaaaaradfpfpjogoytgqvbi3u2mpqolhw67nqo5ixdvk73ddhvma3fc2a"
      OCI_PUBKEY_FINGERPRINT="5b:0a:43:58:38:3c:47:e7:77:e9:9e:4b:78:46:cb:54"
      OCI_REGION="us-ashburn-1"
      OCI_COMPARTMENT_OCID="ocid1.compartment.oc1..aaaaaaaab43r2p524h5pkbefi4h4t4gc7opza22u732sk66wdanfbetiewoq"
#      OCI_POLLING_INTERVAL=10
#      OCI_PROPAGATION_TIMEOUT=600
#      OCI_TTL=30
    }
  }
}

output "private_key_pem" {
  value = "${acme_certificate.certificate[0].private_key_pem}"
}
output "certificate_pem" {
  value = "${acme_certificate.certificate[0].certificate_pem}${acme_certificate.certificate[0].issuer_pem}"
}
