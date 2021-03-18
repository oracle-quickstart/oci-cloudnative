resource "oci_dns_zone" "mushop_dns_zone" {
  # Conditional
  count = var.enable_dns_zone ? 1 : 0

  #Required
  compartment_id = var.lb_compartment_ocid
  name = var.dns_zone_name
  zone_type = "PRIMARY"

}

resource "oci_dns_rrset" "mushop-internal" {
  # Conditional
  count = var.enable_dns_zone ? 1 : 0

  #Required
  domain = local.dns_lb_domain
  rtype = "A"
  zone_name_or_id = oci_dns_zone.mushop_dns_zone[0].name

  #Optional
  compartment_id = var.lb_compartment_ocid
  items {
    #Required
    domain = local.dns_lb_domain
    rdata = lookup(oci_load_balancer_load_balancer.mushop_lb.ip_address_details[0], "ip_address")
    rtype = "A"
    ttl = 30
  }
}

resource "oci_dns_rrset" "mushop-waf" {
  # Conditional
  count = var.enable_dns_zone&&var.enable_waf ? 1 : 0

  #Required
  domain = local.dns_waf_domain
  rtype = "CNAME"
  zone_name_or_id = oci_dns_zone.mushop_dns_zone[0].name

  #Optional
  compartment_id = var.lb_compartment_ocid
  items {
    #Required - UPDATE ME
    domain = local.dns_waf_domain
    rdata = oci_waas_waas_policy.mushop_waf_policy[0].cname
    rtype = "CNAME"
    ttl = 30
  }
}

