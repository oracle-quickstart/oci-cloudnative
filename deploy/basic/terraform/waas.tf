resource "oci_waas_certificate" "mushop_waf_certificate" {
  # Enable WAF or not
  count = var.enable_waf ? 1 : 0

  display_name = "mushop-waf-certificate-${random_string.deploy_id.result}"
  certificate_data = "${acme_certificate.certificate[0].certificate_pem}${acme_certificate.certificate[0].issuer_pem}"
  compartment_id = var.lb_compartment_ocid
  private_key_data = "${acme_certificate.certificate[0].private_key_pem}"
}

resource oci_waas_waas_policy mushop_waf_policy {
  # Enable WAF or not 
  count = var.enable_waf ? 1 : 0

  compartment_id = var.lb_compartment_ocid
  display_name = "mushop-waf-policy-${random_string.deploy_id.result}"
  domain       = "${var.dns_waf_entry}.${var.dns_zone_name}"
  origin_groups {
    label = "Default Group"
    origin_group {
      origin = "mushop"
      weight = "1"
    }
  }
  origins {
    http_port  = "80"
    https_port = "443"
    label      = "mushop"
    uri        = "${var.dns_lb_entry}.${var.dns_zone_name}"
  }
  policy_config {
    certificate_id        = oci_waas_certificate.mushop_waf_certificate[0].id
    is_behind_cdn                 = "false"
    is_cache_control_respected    = "false"
    is_https_enabled              = "true"
    is_https_forced               = "true"
    is_origin_compression_enabled = "true"
    is_response_buffering_enabled = "false"
    is_sni_enabled                = "false"
    load_balancing_method {
      method = "IP_HASH"
    }
    tls_protocols = [
      "TLS_V1_2",
      "TLS_V1_3",
    ]
  }
  waf_config {
    dynamic "captchas" {
      for_each = var.enable_captcha_challenge ? [1] : []  
        content {
          #Required
          failure_message = var.waas_policy_waf_config_captchas_failure_message
          session_expiration_in_seconds = var.waas_policy_waf_config_captchas_session_expiration_in_seconds
          submit_label = var.waas_policy_waf_config_captchas_submit_label
          title = var.waas_policy_waf_config_captchas_title
          url = var.waas_policy_waf_config_captchas_url

          #Optional
          footer_text = var.waas_policy_waf_config_captchas_footer_text
          header_text = var.waas_policy_waf_config_captchas_header_text
       }
    }

    origin = "mushop"
    origin_groups = [
      "Default Group",
    ]
  }
}

######################
locals {
  waf_certificate_data = "${acme_certificate.certificate[0].certificate_pem}${acme_certificate.certificate[0].issuer_pem}"
}
