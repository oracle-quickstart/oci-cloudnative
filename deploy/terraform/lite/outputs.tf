# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
output "Mushop" {
  value = "${oci_load_balancer_load_balancer.mushop_lb.ip_address_details}"
}

output "autonomous_database_password" {
  value = "${random_string.autonomous_database_wallet_password.result}"
}

output "dev" {
  value = "Made with \u2764 by Oracle A-Team"
}


