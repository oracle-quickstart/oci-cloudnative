resource "oci_load_balancer_load_balancer" "mushop_lb" {

  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushop-${random_id.mushop_id.dec}"
  shape          = "${local.lb_shape}"
  subnet_ids     = ["${oci_core_subnet.mushopLBSubnet.id}"]
  is_private     = "false"
  freeform_tags  = "${local.common_tags}"

}

resource "oci_load_balancer_backend_set" "mushop-bes" {
  name             = "mushop-${random_id.mushop_id.dec}"
  load_balancer_id = "${oci_load_balancer_load_balancer.mushop_lb.id}"
  policy           = "IP_HASH"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/api/health"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 10
  }
}

resource "oci_load_balancer_backend" "mushop-be" {
  count            = "${var.num_nodes}"
  load_balancer_id = "${oci_load_balancer_load_balancer.mushop_lb.id}"
  backendset_name  = "${oci_load_balancer_backend_set.mushop-bes.name}"
  ip_address       = "${element(oci_core_instance.app-instance.*.private_ip, count.index)}"
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_listener" "mushop_listener" {
  #Required

  load_balancer_id         = "${oci_load_balancer_load_balancer.mushop_lb.id}"
  default_backend_set_name = "${oci_load_balancer_backend_set.mushop-bes.name}"
  name                     = "mushop-${random_id.mushop_id.dec}"
  port                     = 80
  protocol                 = "HTTP"

  #Optional
  connection_configuration {
    #Required
    idle_timeout_in_seconds = "30"
  }

}
