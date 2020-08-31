# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_objectstorage_bucket" "mushop" {
  compartment_id = var.compartment_ocid
  name           = "mushop-${random_string.deploy_id.result}"
  namespace      = data.oci_objectstorage_namespace.user_namespace.namespace
  freeform_tags  = local.common_tags
  kms_key_id     = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? oci_kms_key.mushop_key[0].id : var.encryption_key_id) : null
  depends_on     = [oci_identity_policy.mushop_basic_policies]
}

resource "oci_objectstorage_object" "mushop_wallet" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = data.oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "mushop_atp_wallet"
}

resource "oci_objectstorage_preauthrequest" "mushop_wallet_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = "mushop_wallet_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object       = oci_objectstorage_object.mushop_wallet.object
}

resource "oci_objectstorage_object" "catalogue_sql_script" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = file("./scripts/atp_mushop_catalogue.sql")
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "catalogue_sql_script"
}

resource "oci_objectstorage_preauthrequest" "catalogue_sql_script_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = "catalogue_sql_script_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object       = oci_objectstorage_object.catalogue_sql_script.object
}

resource "oci_objectstorage_object" "apache_conf" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = file("./scripts/httpd.conf")
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "apache_conf"
}

resource "oci_objectstorage_preauthrequest" "apache_conf_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = "apache_conf_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object       = oci_objectstorage_object.apache_conf.object
}

resource "oci_objectstorage_object" "entrypoint" {
  bucket    = oci_objectstorage_bucket.mushop.name
  content   = file("./scripts/entrypoint.sh")
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "entrypoint"
}

resource "oci_objectstorage_preauthrequest" "entrypoint_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = "entrypoint_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object       = oci_objectstorage_object.entrypoint.object
}

resource "oci_objectstorage_object" "mushop_basic" {
  bucket    = oci_objectstorage_bucket.mushop.name
  source    = "./scripts/mushop-basic.tar.gz"
  namespace = data.oci_objectstorage_namespace.user_namespace.namespace
  object    = "mushop_basic"
}

resource "oci_objectstorage_preauthrequest" "mushop_lite_preauth" {
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.mushop.name
  name         = "mushop_lite_preauth"
  namespace    = data.oci_objectstorage_namespace.user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object       = oci_objectstorage_object.mushop_basic.object
}

# Static assets bucket
resource "oci_objectstorage_bucket" "mushop_media" {
  compartment_id = (var.object_storage_mushop_media_compartment_ocid != "") ? var.object_storage_mushop_media_compartment_ocid : var.compartment_ocid
  name           = "mushop-media-${random_string.deploy_id.result}"
  namespace      = data.oci_objectstorage_namespace.user_namespace.namespace
  freeform_tags  = local.common_tags
  access_type    = (var.object_storage_mushop_media_visibility == "Private") ? "NoPublicAccess" : "ObjectReadWithoutList"
  kms_key_id     = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? oci_kms_key.mushop_key[0].id : var.encryption_key_id) : null
}

# Static assets write PAR
resource "oci_objectstorage_preauthrequest" "mushop_media_preauth" {
  bucket       = oci_objectstorage_bucket.mushop_media.name
  namespace    = oci_objectstorage_bucket.mushop_media.namespace
  access_type  = "AnyObjectWrite"
  name         = "mushop_assets_preauth"
  time_expires = timeadd(timestamp(), "30m")
}

# Static product media
resource "oci_objectstorage_object" "mushop_media" {
  for_each = fileset("./images", "**")

  bucket        = oci_objectstorage_bucket.mushop_media.name
  namespace     = oci_objectstorage_bucket.mushop_media.namespace
  object        = each.value
  source        = "./images/${each.value}"
  content_type  = "image/png"
  cache_control = "max-age=604800, public, no-transform"
}