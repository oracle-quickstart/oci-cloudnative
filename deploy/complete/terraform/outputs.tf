# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "mushop_url_button" {
  value       = format("http://%s", local.mushop_ingress_ip)
  description = "MuShop Storefront URL for ORM button"

  depends_on = [helm_release.ingress_nginx]
}
output "mushop_url" {
  value       = format("http://%s", local.mushop_ingress_ip)
  description = "MuShop Storefront URL"

  depends_on = [helm_release.ingress_nginx]
}
output "mushop_url_https" {
  value       = format("https://%s", local.mushop_ingress_hostname)
  description = "MuShop Storefront Hostname"

  depends_on = [helm_release.ingress_nginx]
}
output "grafana_url" {
  value       = format("http://%s/grafana", local.mushop_ingress_ip)
  description = "Grafana Dashboards URL"

  depends_on = [helm_release.ingress_nginx]
}
output "external_ip" {
  value = local.mushop_ingress_ip

  depends_on = [helm_release.ingress_nginx]
}
output "autonomous_database_password" {
  value     = random_string.autonomous_database_admin_password.result
}
output "grafana_admin_password" {
  value     = nonsensitive(data.kubernetes_secret.mushop_utils_grafana.data.admin-password)
}
output "mushop_source_code" {
  value = "https://github.com/oracle-quickstart/oci-cloudnative/"
}
locals {
  mushop_ingress_ip       = data.kubernetes_service.mushop_ingress.load_balancer_ingress[0].ip
  mushop_ingress_hostname = data.kubernetes_service.mushop_ingress.load_balancer_ingress[0].hostname == "" ? data.kubernetes_service.mushop_ingress.load_balancer_ingress[0].ip : data.kubernetes_service.mushop_ingress.load_balancer_ingress[0].hostname
}