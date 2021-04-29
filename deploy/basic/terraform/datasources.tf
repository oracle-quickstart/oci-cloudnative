# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
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

# Cloud Init
data "template_cloudinit_config" "nodes" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
}
data "template_file" "cloud_init" {
  template = file("${path.module}/scripts/cloud-config.template.yaml")

  vars = {
    setup_preflight_sh_content     = base64gzip(data.template_file.setup_preflight.rendered)
    setup_template_sh_content      = base64gzip(data.template_file.setup_template.rendered)
    deploy_template_content        = base64gzip(data.template_file.deploy_template.rendered)
    catalogue_sql_template_content = base64gzip(data.template_file.catalogue_sql_template.rendered)
    httpd_conf_content             = base64gzip(data.local_file.httpd_conf.content)
    mushop_media_pars_list_content = base64gzip(data.template_file.mushop_media_pars_list.rendered)
    catalogue_password             = random_string.catalogue_db_password.result
    catalogue_port                 = local.catalogue_port
    mock_mode                      = var.services_in_mock_mode
    db_name                        = oci_database_autonomous_database.mushop_autonomous_database.db_name
    assets_url                     = var.object_storage_mushop_media_visibility == "Private" ? "" : "https://objectstorage.${var.region}.oraclecloud.com/n/${oci_objectstorage_bucket.mushop_media.namespace}/b/${oci_objectstorage_bucket.mushop_media.name}/o/"
  }
}
data "template_file" "setup_preflight" {
  template = file("${path.module}/scripts/setup.preflight.sh")
}
data "template_file" "setup_template" {
  template = file("${path.module}/scripts/setup.template.sh")

  vars = {
    oracle_client_version = var.oracle_client_version
  }
}
data "template_file" "deploy_template" {
  template = file("${path.module}/scripts/deploy.template.sh")

  vars = {
    oracle_client_version   = var.oracle_client_version
    db_name                 = oci_database_autonomous_database.mushop_autonomous_database.db_name
    atp_pw                  = random_string.autonomous_database_admin_password.result
    mushop_media_visibility = var.object_storage_mushop_media_visibility
    mushop_app_par          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_lite_preauth.access_uri}"
    wallet_par              = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"
  }
}
data "template_file" "catalogue_sql_template" {
  template = file("${path.module}/scripts/catalogue.template.sql")

  vars = {
    catalogue_password = random_string.catalogue_db_password.result
  }
}
data "local_file" "httpd_conf" {
  filename = "${path.module}/scripts/httpd.conf"
}
data "template_file" "mushop_media_pars_list" {
  template = file("./scripts/mushop_media_pars_list.txt")
  vars = {
    content = local.mushop_media_pars
  }
}
locals {
  catalogue_port = 3005
}


# Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  common_tags = {
    Reference = "Created by OCI QuickStart for MuShop Basic demo"
  }
}
