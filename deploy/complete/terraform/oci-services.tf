# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Services
## Autonomous Database
### creates an ATP database
resource "oci_database_autonomous_database" "mushop_autonomous_database" {
  count                    = var.mushop_mock_mode_all ? 0 : 1
  admin_password           = random_string.autonomous_database_admin_password.result
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.autonomous_database_cpu_core_count
  data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
  data_safe_status         = var.autonomous_database_data_safe_status
  db_version               = var.autonomous_database_db_version
  db_name                  = "mushopdb${random_string.deploy_id.result}"
  display_name             = "${var.cluster_name}-Db-${random_string.deploy_id.result}"
  license_model            = var.autonomous_database_license_model
  is_auto_scaling_enabled  = var.autonomous_database_is_auto_scaling_enabled
  is_free_tier             = var.autonomous_database_is_free_tier
}
### Wallet
resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  count                  = var.mushop_mock_mode_all ? 0 : 1
  autonomous_database_id = oci_database_autonomous_database.mushop_autonomous_database[0].id
  password               = random_string.autonomous_database_wallet_password.result
  generate_type          = var.autonomous_database_wallet_generate_type
  base64_encode_content  = true
}

resource "kubernetes_secret" "oadb-admin" {
  count = var.mushop_mock_mode_all ? 0 : 1
  metadata {
    name      = var.db_admin_name
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    oadb_admin_pw = random_string.autonomous_database_admin_password.result
  }
  type = "Opaque"
}

resource "kubernetes_secret" "oadb-connection" {
  count = var.mushop_mock_mode_all ? 0 : 1
  metadata {
    name      = var.db_connection_name
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    oadb_wallet_pw = random_string.autonomous_database_wallet_password.result
    oadb_service   = "mushopdb${random_string.deploy_id.result}_TP"
  }
  type = "Opaque"
}

### OADB Wallet extraction <>
resource "kubernetes_secret" "oadb_wallet_zip" {
  count = var.mushop_mock_mode_all ? 0 : 1
  metadata {
    name      = "oadb-wallet-zip"
    namespace = kubernetes_namespace.mushop_namespace.id
  }
  data = {
    wallet = oci_database_autonomous_database_wallet.autonomous_database_wallet[0].content
  }
  type = "Opaque"
}
resource "kubernetes_cluster_role" "secret_creator" {
  count = var.mushop_mock_mode_all ? 0 : 1
  metadata {
    name = "secret-creator"
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }
}
resource "kubernetes_cluster_role_binding" "wallet_extractor_crb" {
  count = var.mushop_mock_mode_all ? 0 : 1
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
}
resource "kubernetes_service_account" "wallet_extractor_sa" {
  count = var.mushop_mock_mode_all ? 0 : 1
  metadata {
    name      = "wallet-extractor-sa"
    namespace = kubernetes_namespace.mushop_namespace.id
  }
}
resource "kubernetes_job" "wallet_extractor_job" {
  count = var.mushop_mock_mode_all ? 0 : 1
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
    backoff_limit = 1
    # ttl_seconds_after_finished = 120 # Not supported by TF K8s provider 1.8. ORM need to update provider
  }
}
### OADB Wallet extraction </>

## Object Storage
resource "oci_objectstorage_bucket" "mushop_catalogue_bucket" {
  count          = var.mushop_mock_mode_all ? 0 : 1
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "mushop-catalogue-bucket-${random_string.deploy_id.result}"
  access_type    = "ObjectReadWithoutList"
}

resource "oci_objectstorage_preauthrequest" "mushop_catalogue_bucket_par" {
  count        = var.mushop_mock_mode_all ? 0 : 1
  namespace    = data.oci_objectstorage_namespace.ns.namespace
  bucket       = oci_objectstorage_bucket.mushop_catalogue_bucket[0].name
  name         = "mushop-catalogue-bucket-par-${random_string.deploy_id.result}"
  access_type  = "AnyObjectWrite"
  time_expires = timeadd(timestamp(), "60m")
}

resource "kubernetes_secret" "oos_bucket" {
  count = var.mushop_mock_mode_all ? 0 : 1
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
}