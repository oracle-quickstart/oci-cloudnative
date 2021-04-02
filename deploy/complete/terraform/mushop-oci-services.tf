# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OCI Services
## Autonomous Database
### creates an ATP database
resource "oci_database_autonomous_database" "mushop_autonomous_database" {
  admin_password           = random_string.autonomous_database_admin_password.result
  compartment_id           = local.oke_compartment_ocid
  cpu_core_count           = var.autonomous_database_cpu_core_count
  data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
  data_safe_status         = var.autonomous_database_data_safe_status
  db_version               = var.autonomous_database_db_version
  db_name                  = "mushopdb${random_string.deploy_id.result}"
  display_name             = "${var.cluster_name}-Db-${random_string.deploy_id.result}"
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
    oadb_service   = "mushopdb${random_string.deploy_id.result}_TP"
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
    backoff_limit = 1
    # ttl_seconds_after_finished = 120 # Not supported by TF K8s provider 1.8. ORM need to update provider
  }

  count = var.mushop_mock_mode_all ? 0 : 1
}
### OADB Wallet extraction </>

## Object Storage
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

## OCI KMS Vault
### OCI Vault vault
resource "oci_kms_vault" "mushop_vault" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "${local.vault_display_name} - ${random_string.deploy_id.result}"
  vault_type     = local.vault_type[0]

  depends_on = [oci_identity_policy.kms_compartment_policies]

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}
### OCI Vault key
resource "oci_kms_key" "mushop_key" {
  compartment_id      = local.oke_compartment_ocid
  display_name        = "${local.vault_key_display_name} - ${random_string.deploy_id.result}"
  management_endpoint = oci_kms_vault.mushop_vault[0].management_endpoint

  key_shape {
    algorithm = local.vault_key_key_shape_algorithm
    length    = local.vault_key_key_shape_length
  }

  count = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? 1 : 0) : 0
}

### Vault and Key definitions

locals {
  vault_display_name            = "MuShop Vault"
  vault_key_display_name        = "MuShop Key"
  vault_key_key_shape_algorithm = "AES"
  vault_key_key_shape_length    = 32
  vault_type                    = ["DEFAULT", "VIRTUAL_PRIVATE"]
}
