# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "dev" {
  value = "Made with \u2764 by Oracle Developers"
}
output "deploy_id" {
  value = random_string.deploy_id.result
}
output "deployed_to_region" {
  value = var.region
}
output "mushop_source_code" {
  value = "https://github.com/oracle-quickstart/oci-cloudnative/"
}
output "sensitive_comments_local_tf" {
  value = "To get sensitive outputs, use `terraform output autonomous_database_password` or `terraform output grafana_admin_password` or `terraform output generated_private_key_pem`"
}
