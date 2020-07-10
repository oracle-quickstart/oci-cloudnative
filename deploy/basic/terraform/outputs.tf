# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "lb_public_url" {
  value = format("http://%s", lookup(oci_load_balancer_load_balancer.mushop_lb.ip_address_details[0], "ip_address"))
}

output "autonomous_database_password" {
  value = random_string.autonomous_database_wallet_password.result
}

output "generated_public_ssh_key" {
  value = var.generate_public_ssh_key ? tls_private_key.compute_ssh_key.public_key_openssh : "No Keys Auto Generated"
}

output "dev" {
  value = "Made with \u2764 by Oracle A-Team"
}

output "comments" {
  value = "The application URL will be unavailable for a few minutes after provisioning, while the application is configured"
}


