# Copyright (c) 2019-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Gets ObjectStorage namespace
data "oci_objectstorage_namespace" "user_namespace" {
  compartment_id = var.compartment_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

### Passwords using random_string instead of random_password to be compatible with ORM (Need to update random provider)
resource "random_string" "autonomous_database_wallet_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}

resource "random_string" "autonomous_database_admin_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}

resource "random_string" "catalogue_db_password" {
  length           = 16
  special          = true
  min_upper        = 3
  min_lower        = 3
  min_numeric      = 3
  min_special      = 3
  override_special = "{}#^*<>[]%~"
}

# Check for resource limits
## Check available compute shape
data "oci_limits_services" "compute_services" {
  compartment_id = var.tenancy_ocid

  filter {
    name   = "name"
    values = ["compute"]
  }
}
data "oci_limits_limit_definitions" "compute_limit_definitions" {
  compartment_id = var.tenancy_ocid
  service_name   = data.oci_limits_services.compute_services.services.0.name

  filter {
    name   = "description"
    values = [local.compute_shape_description]
  }
}
data "oci_limits_resource_availability" "compute_resource_availability" {
  compartment_id      = var.tenancy_ocid
  limit_name          = data.oci_limits_limit_definitions.compute_limit_definitions.limit_definitions[0].name
  service_name        = data.oci_limits_services.compute_services.services.0.name
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[count.index].name

  count = length(data.oci_identity_availability_domains.ADs.availability_domains)
}
resource "random_shuffle" "compute_ad" {
  input        = local.compute_available_limit_ad_list
  result_count = length(local.compute_available_limit_ad_list)
}
locals {
  compute_multiplier_nodes_ocpus  = local.is_flexible_instance_shape ? (var.num_nodes * var.instance_ocpus) : var.num_nodes
  compute_available_limit_ad_list = [for limit in data.oci_limits_resource_availability.compute_resource_availability : limit.availability_domain if(limit.available - local.compute_multiplier_nodes_ocpus) >= 0]
  compute_available_limit_check = length(local.compute_available_limit_ad_list) == 0 ? (
  file("ERROR: No limits available for the chosen compute shape and number of nodes or OCPUs")) : 0
}

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "compute_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = local.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid

  provider = oci.current_region
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }

  provider = oci.current_region
}

# Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Cloud Init
data "cloudinit_config" "nodes" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = local.cloud_init
  }
}

## Files and Templatefiles
locals {
  httpd_conf      = file("${path.module}/scripts/httpd.conf")
  setup_preflight = file("${path.module}/scripts/setup.preflight.sh")
  setup_template = templatefile("${path.module}/scripts/setup.template.sh",
    {
      oracle_client_version = var.oracle_client_version
  })
  deploy_template = templatefile("${path.module}/scripts/deploy.template.sh",
    {
      oracle_client_version   = var.oracle_client_version
      db_name                 = oci_database_autonomous_database.mushop_autonomous_database.db_name
      atp_pw                  = random_string.autonomous_database_admin_password.result
      mushop_media_visibility = var.object_storage_mushop_media_visibility
      mushop_app_par          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_lite_preauth.access_uri}"
      wallet_par              = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"
      oda_enabled             = var.oda_enabled
      oda_uri                 = var.oda_uri
      oda_channel_id          = var.oda_channel_id
      oda_secret              = var.oda_secret
      oda_user_init_message   = var.oda_user_init_message
  })
  catalogue_sql_template = templatefile("${path.module}/scripts/catalogue.template.sql",
    {
      catalogue_password = random_string.catalogue_db_password.result
  })
  mushop_media_pars_list = templatefile("${path.module}/scripts/mushop_media_pars_list.txt",
    {
      content = local.mushop_media_pars
  })
  cloud_init = templatefile("${path.module}/scripts/cloud-config.template.yaml",
    {
      setup_preflight_sh_content     = base64gzip(local.setup_preflight)
      setup_template_sh_content      = base64gzip(local.setup_template)
      deploy_template_content        = base64gzip(local.deploy_template)
      catalogue_sql_template_content = base64gzip(local.catalogue_sql_template)
      httpd_conf_content             = base64gzip(local.httpd_conf)
      mushop_media_pars_list_content = base64gzip(local.mushop_media_pars_list)
      catalogue_password             = random_string.catalogue_db_password.result
      catalogue_port                 = local.catalogue_port
      catalogue_architecture         = split("/", local.compute_platform)[1]
      mock_mode                      = var.services_in_mock_mode
      db_name                        = oci_database_autonomous_database.mushop_autonomous_database.db_name
      assets_url                     = var.object_storage_mushop_media_visibility == "Private" ? "" : "https://objectstorage.${var.region}.oraclecloud.com/n/${oci_objectstorage_bucket.mushop_media.namespace}/b/${oci_objectstorage_bucket.mushop_media.name}/o/"
  })
}

# Catalogue port
locals {
  catalogue_port = 3005
}



# Tags
locals {
  common_tags = {
    Reference = "Created by OCI QuickStart for MuShop Basic demo"
  }
}
