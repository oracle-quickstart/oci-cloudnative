# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Services
##**************************************************************************
##                        Autonomous Database
##**************************************************************************

### creates an ATP database
resource "oci_database_autonomous_database" "mushop_autonomous_database" {
  admin_password           = random_string.autonomous_database_admin_password.result
  compartment_id           = local.oke_compartment_ocid
  cpu_core_count           = var.autonomous_database_cpu_core_count
  data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
  data_safe_status         = var.autonomous_database_data_safe_status
  db_version               = var.autonomous_database_db_version
  db_name                  = "${local.app_name_for_db}${random_string.deploy_id.result}"
  display_name             = "${var.app_name} Db (${random_string.deploy_id.result})"
  license_model            = var.autonomous_database_license_model
  is_auto_scaling_enabled  = var.autonomous_database_is_auto_scaling_enabled
  is_free_tier             = var.autonomous_database_is_free_tier

  count = var.mushop_mock_mode_all ? 0 : 1
}
### Wallet
resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.mushop_autonomous_database[0].id
  password               = random_string.autonomous_database_wallet_password.result
  generate_type          = var.autonomous_database_wallet_generate_type
  base64_encode_content  = true

  count = var.mushop_mock_mode_all ? 0 : 1
}

resource "kubernetes_secret" "oadb-admin" {
  metadata {
    name      = var.db_admin_name
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    oadb_admin_pw = random_string.autonomous_database_admin_password.result
  }
  type = "Opaque"

  count = var.mushop_mock_mode_all ? 0 : 1
}

resource "kubernetes_secret" "oadb-connection" {
  metadata {
    name      = var.db_connection_name
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    oadb_wallet_pw = random_string.autonomous_database_wallet_password.result
    oadb_service   = "${local.app_name_for_db}${random_string.deploy_id.result}_TP"
  }
  type = "Opaque"

  count = var.mushop_mock_mode_all ? 0 : 1
}

### OADB Wallet extraction <>
resource "kubernetes_secret" "oadb_wallet_zip" {
  metadata {
    name      = "oadb-wallet-zip"
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    wallet = oci_database_autonomous_database_wallet.autonomous_database_wallet[0].content
  }
  type = "Opaque"

  count = var.mushop_mock_mode_all ? 0 : 1
}
resource "kubernetes_cluster_role" "secret_creator" {
  metadata {
    name = "secret-creator"
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }

  count = var.mushop_mock_mode_all ? 0 : 1
}
resource "kubernetes_cluster_role_binding" "wallet_extractor_crb" {
  metadata {
    name = "wallet-extractor-crb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.secret_creator[0].metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.wallet_extractor_sa[0].metadata.0.name
    namespace = kubernetes_namespace.mushop_namespace.id
  }

  count = var.mushop_mock_mode_all ? 0 : 1
}
resource "kubernetes_service_account" "wallet_extractor_sa" {
  metadata {
    name      = "wallet-extractor-sa"
    namespace = kubernetes_namespace.mushop_namespace.id
  }

  count = var.mushop_mock_mode_all ? 0 : 1
}
resource "kubernetes_job" "wallet_extractor_job" {
  metadata {
    name      = "wallet-extractor-job"
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  spec {
    template {
      metadata {}
      spec {
        init_container {
          name    = "wallet-extractor"
          image   = "busybox"
          command = ["/bin/sh", "-c"]
          args    = ["base64 -d /tmp/zip/wallet > /tmp/wallet.zip && unzip /tmp/wallet.zip -d /wallet"]
          volume_mount {
            mount_path = "/tmp/zip"
            name       = "wallet-zip"
            read_only  = true
          }
          volume_mount {
            mount_path = "/wallet"
            name       = "wallet"
          }
        }
        container {
          name    = "wallet-binding"
          image   = "bitnami/kubectl"
          command = ["/bin/sh", "-c"]
          args    = ["kubectl create secret generic oadb-wallet --from-file=/wallet"]
          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.wallet_extractor_sa[0].default_secret_name
            read_only  = true
          }
          volume_mount {
            mount_path = "/wallet"
            name       = "wallet"
            read_only  = true
          }
        }
        volume {
          name = kubernetes_service_account.wallet_extractor_sa[0].default_secret_name
          secret {
            secret_name = kubernetes_service_account.wallet_extractor_sa[0].default_secret_name
          }
        }
        volume {
          name = "wallet-zip"
          secret {
            secret_name = kubernetes_secret.oadb_wallet_zip[0].metadata.0.name
          }
        }
        volume {
          name = "wallet"
          empty_dir {}
        }
        restart_policy       = "Never"
        service_account_name = "wallet-extractor-sa"
      }
    }
    backoff_limit              = 1
    ttl_seconds_after_finished = 120
  }

  depends_on = [kubernetes_deployment.cluster_autoscaler_deployment, helm_release.ingress_nginx]

  count = var.mushop_mock_mode_all ? 0 : 1
}
### OADB Wallet extraction </>

##**************************************************************************
##                          Object Storage
##**************************************************************************
resource "oci_objectstorage_bucket" "mushop_catalogue_bucket" {
  compartment_id = local.oke_compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "mushop-catalogue-bucket-${random_string.deploy_id.result}"
  access_type    = "ObjectReadWithoutList"

  count = var.mushop_mock_mode_all ? 0 : 1
}

resource "oci_objectstorage_preauthrequest" "mushop_catalogue_bucket_par" {
  namespace    = data.oci_objectstorage_namespace.ns.namespace
  bucket       = oci_objectstorage_bucket.mushop_catalogue_bucket[0].name
  name         = "mushop-catalogue-bucket-par-${random_string.deploy_id.result}"
  access_type  = "AnyObjectWrite"
  time_expires = timeadd(timestamp(), "60m")

  count = var.mushop_mock_mode_all ? 0 : 1
}

resource "kubernetes_secret" "oos_bucket" {
  metadata {
    name      = var.oos_bucket_name
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    region    = var.region
    name      = "mushop-catalogue-bucket-${random_string.deploy_id.result}"
    namespace = data.oci_objectstorage_namespace.ns.namespace
    parUrl    = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_catalogue_bucket_par[0].access_uri}"
  }
  type = "Opaque"

  count = var.mushop_mock_mode_all ? 0 : 1
}

##**************************************************************************
##                        OCI Service User
##**************************************************************************

### OCI Service User
resource "oci_identity_user" "oci_service_user" {
  compartment_id = var.tenancy_ocid
  description    = "${var.app_name} Service User for deployment ${random_string.deploy_id.result}"
  name           = "${local.app_name_normalized}-service-user-${random_string.deploy_id.result}"

  provider = oci.home_region

  count = var.create_oci_service_user ? 1 : 0
}
resource "oci_identity_group" "oci_service_user" {
  compartment_id = var.tenancy_ocid
  description    = "${var.app_name} Service User Group for deployment ${random_string.deploy_id.result}"
  name           = "${local.app_name_normalized}-service-user-group-${random_string.deploy_id.result}"

  provider = oci.home_region

  count = var.create_oci_service_user ? 1 : 0
}
resource "oci_identity_user_group_membership" "oci_service_user" {
  group_id = oci_identity_group.oci_service_user[0].id
  user_id  = oci_identity_user.oci_service_user[0].id

  provider = oci.home_region

  count = var.create_oci_service_user ? 1 : 0
}
resource "oci_identity_user_capabilities_management" "oci_service_user" {
  user_id = oci_identity_user.oci_service_user[0].id

  can_use_api_keys             = "false"
  can_use_auth_tokens          = "false"
  can_use_console_password     = "false"
  can_use_customer_secret_keys = "false"
  can_use_smtp_credentials     = var.newsletter_subscription_enabled ? "true" : "false"

  provider = oci.home_region

  count = var.create_oci_service_user ? 1 : 0
}
resource "oci_identity_smtp_credential" "oci_service_user" {
  description = "${local.app_name_normalized}-service-user-smtp-credential-${random_string.deploy_id.result}"
  user_id     = oci_identity_user.oci_service_user[0].id

  provider = oci.home_region

  count = var.create_oci_service_user ? (oci_identity_user_capabilities_management.oci_service_user.0.can_use_smtp_credentials ? 1 : 0) : 0
}

##**************************************************************************
##                        OCI Email Delivery
##**************************************************************************

### Email Sender
resource "oci_email_sender" "newsletter_email_sender" {
  compartment_id = local.oke_compartment_ocid
  email_address  = local.newsletter_email_sender

  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
}

##**************************************************************************
##                      Oracle Cloud Functions
##**************************************************************************

resource "oci_functions_application" "app_function" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "${var.app_name} Application (${random_string.deploy_id.result})"
  subnet_ids     = [oci_core_subnet.apigw_fn_subnet.0.id, ]

  config     = {}
  syslog_url = ""
  trace_config {
    domain_id  = ""
    is_enabled = "false"
  }

  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
}

resource "oci_functions_function" "newsletter_subscription" {
  application_id = oci_functions_application.app_function.0.id
  display_name   = local.newsletter_function_display_name
  image          = "${var.newsletter_subscription_function_image}:${var.newsletter_subscription_function_image_version}"
  memory_in_mbs  = local.newsletter_function_memory_in_mbs
  config = {
    "APPROVED_SENDER_EMAIL" : local.newsletter_email_sender,
    "SMTP_HOST" : local.newsletter_function_smtp_host,
    "SMTP_PORT" : local.newsletter_function_smtp_port,
    "SMTP_USER" : oci_identity_smtp_credential.oci_service_user.0.username,
    "SMTP_PASSWORD" : oci_identity_smtp_credential.oci_service_user.0.password,
  }

  timeout_in_seconds = local.newsletter_function_timeout_in_seconds
  trace_config {
    is_enabled = "false"
  }

  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
}
locals {
  newsletter_function_display_name       = "newsletter-subscription"
  newsletter_email_sender                = replace(var.newsletter_email_sender, "@", "+${random_string.deploy_id.result}@")
  newsletter_function_memory_in_mbs      = "128"
  newsletter_function_timeout_in_seconds = "60"
  newsletter_function_smtp_host          = "smtp.email.${var.region}.oci.oraclecloud.com"
  newsletter_function_smtp_port          = "587"
}

##**************************************************************************
##                          OCI API Gateway
##**************************************************************************

resource "oci_apigateway_gateway" "app_gateway" {
  compartment_id = local.oke_compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.apigw_fn_subnet.0.id
  display_name   = "${var.app_name} API Gateway (${random_string.deploy_id.result})"

  response_cache_details {
    type = "NONE"
  }

  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
}

resource "oci_apigateway_deployment" "newsletter_subscription" {
  compartment_id = local.oke_compartment_ocid
  gateway_id     = oci_apigateway_gateway.app_gateway.0.id
  path_prefix    = "/newsletter"

  display_name = local.newsletter_function_display_name

  specification {
    logging_policies {
      execution_log {
        is_enabled = "true"
        log_level  = "ERROR"
      }
    }

    routes {
      backend {
        function_id = oci_functions_function.newsletter_subscription.0.id
        type        = "ORACLE_FUNCTIONS_BACKEND"
      }
      logging_policies {

      }
      methods = ["POST", ]
      path    = "/subscribe"
    }
  }

  count = var.create_new_oke_cluster ? (var.newsletter_subscription_enabled ? 1 : 0) : 0
}
