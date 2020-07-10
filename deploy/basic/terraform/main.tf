# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 0.12.16"
}
data "template_file" "mushop" {
  template = "${file("./scripts/node.sh")}"
}

resource "oci_core_instance" "app-instance" {
  count               = var.num_nodes
  availability_domain = local.availability_domain[0]
  compartment_id      = var.compartment_ocid
  display_name        = "mushop-${random_id.mushop_id.dec}-${count.index}"
  shape               = var.instance_shape
  freeform_tags       = local.common_tags

  create_vnic_details {
    subnet_id        = oci_core_subnet.mushopLBSubnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "mushop-${random_id.mushop_id.dec}-${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = local.images[var.region]
  }

  metadata = {
    ssh_authorized_keys = var.generate_public_ssh_key ? tls_private_key.compute_ssh_key.public_key_openssh : var.public_ssh_key
    user_data           = base64encode(data.template_file.mushop.rendered)
    db_name             = oci_database_autonomous_database.mushop_autonomous_database.db_name
    atp_pw              = random_string.autonomous_database_wallet_password.result
    catalogue_sql_par   = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.catalogue_sql_script_preauth.access_uri}"
    apache_conf_par     = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.apache_conf_preauth.access_uri}"
    entrypoint_par      = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.entrypoint_preauth.access_uri}"
    mushop_app_par      = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_lite_preauth.access_uri}"
    wallet_par          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_wallet_preauth.access_uri}"
    assets_par          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.mushop_media_preauth.access_uri}"
    assets_url          = "https://objectstorage.${var.region}.oraclecloud.com/n/${oci_objectstorage_bucket.mushop_media.namespace}/b/${oci_objectstorage_bucket.mushop_media.name}/o/"
  }

}

// https://docs.cloud.oracle.com/iaas/images/image/4e74174f-0b44-4447-bb09-dc05b23cf3ee/
// Oracle-Linux-7.7-2019.08.28-0
locals {
  images = {
    ap-mumbai-1    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaanqnm77gq2dpmc2aih2ddlwlahuv2qwmokufb7zbi52v67pzkzycq"
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaav3lc5w7cvz5yr6hpjdubxupjeduzd5xvaroyhjg6vwqzsdvgus6q"
    ap-sydney-1    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaagtfumjxhosxrkgfci3dgwvsmp35ip5nbhy2rypxfh3rwtqsozkcq"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaajousbvplzyrh727e3d4sb6bam5d2fomwhbtzatoun5sqcuvvfjnq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaavr35ze44lkflxffkhmt4xyamkfjpbjhsm5awxjwlnp3gpx7h7fgq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7gj6uot6tz6t34qjzvkldxtwse7gr5m7xvnh6xfm53ddxp3w37ja"
    eu-zurich-1    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaasl3mlhvgzhfglqqkwdbppmmgomkz6iyi42wjkceldqcpecg7jzgq"
    sa-saopaulo-1  = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaawamujpmwxbjgrfeb66zpew5sgz4bimzb4wgcwhqdjyct53bucvoq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa6trfxqtp5ib7yfgj725js3o6agntmv6vckarebsmacrhdxqojeya"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaayuihpsm2nfkxztdkottbjtfjqhgod7hfuirt2rqlewxrmdlgg75q"
    us-langley-1   = "ocid1.image.oc2.us-langley-1.aaaaaaaaazlspcasnl4ibjwu7g5ukiaqjp6xcbk5lqgtdsazd7v6evbkwxcq"
    us-luke-1      = "ocid1.image.oc2.us-luke-1.aaaaaaaa73qnm5jktrwmkutf6iaigib4msieymk2s5r5iweq5yvqublgcx5q"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaadtmpmfm77czi5ghi5zh7uvkguu6dsecsg7kuo3eigc5663und4za"
  }

  availability_domain = [for limit in data.oci_limits_limit_values.test_limit_values : limit.limit_values[0].availability_domain if limit.limit_values[0].value > 0]

  num_nodes = 2

  lb_shape = "10Mbps-Micro"

  common_tags = {
    Reference = "Created by OCI QuickStart for Free Tier"
  }

}

# Generate ssh keys to access Compute Nodes, if generate_public_ssh_key=true, applies to the Compute
resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}