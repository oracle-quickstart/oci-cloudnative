# Copyright (c) 2020, 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create namespace mushop for the mushop microservices
resource "kubernetes_namespace" "mushop_namespace" {
  metadata {
    name = "mushop"
  }
  depends_on = [oci_containerengine_node_pool.oke_node_pool]
}

# Deploy mushop chart
resource "helm_release" "mushop" {
  name      = "mushop"
  chart     = "../helm-chart/mushop"
  namespace = kubernetes_namespace.mushop_namespace.id
  wait      = false

  set {
    name  = "global.mock.service"
    value = var.mushop_mock_mode_all ? "all" : "none"
  }
  set {
    name  = "global.oadbAdminSecret"
    value = var.db_admin_name
  }
  set {
    name  = "global.oadbConnectionSecret"
    value = var.db_connection_name
  }
  set {
    name  = "global.oadbWalletSecret"
    value = var.db_wallet_name
  }
  # set {
  #   name  = "global.oosBucketSecret" # Commented until come with solution to gracefully removal of objects when terraform destroy
  #   value = var.oos_bucket_name
  # }
  set {
    name  = "ingress.enabled"
    value = var.ingress_nginx_enabled
  }
  set {
    name  = "ingress.hosts"
    value = "{${var.ingress_hosts}}"
  }
  set {
    name  = "ingress.clusterIssuer"
    value = var.cert_manager_enabled ? var.ingress_cluster_issuer : ""
  }
  set {
    name  = "ingress.email"
    value = var.ingress_email_issuer
  }
  set {
    name  = "ingress.tls"
    value = var.ingress_tls
  }
  set {
    name  = "tags.atp"
    value = var.mushop_mock_mode_all ? false : true
  }
  set {
    name  = "tags.streaming"
    value = var.mushop_mock_mode_all ? false : false
  }

  set {
    name  = "api.env.newsletterSubscribeUrl"
    value = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? "${oci_apigateway_deployment.newsletter_subscription.0.endpoint}/subscribe" : "") : ""
  }

  set {
    name  = "storefront.env.odaEnabled"
    value = var.oda_enabled
  }
  set {
    name  = "storefront.env.odaUri"
    value = var.oda_uri
  }
  set {
    name  = "storefront.env.odaChannelId"
    value = var.oda_channel_id
  }
  set {
    name  = "storefront.env.odaSecret"
    value = var.oda_channel_secret
  }
  set {
    name  = "storefront.env.odaUserHiddenInitMessage"
    value = var.oda_user_init_message
  }

  depends_on = [helm_release.ingress_nginx, helm_release.cert_manager] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.

  timeout = 500
}
