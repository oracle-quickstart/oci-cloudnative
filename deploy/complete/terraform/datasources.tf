# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "node_pool_images" {
  compartment_id = var.compartment_ocid
  operating_system = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape = var.node_pool_shape
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

resource "random_string" "deploy_id" {
  length = 4
  special = false
}

data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
    cluster_id = oci_containerengine_cluster.oke-mushop_cluster.id
}

# Helm repos

## stable
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}
## incubator
data "helm_repository" "incubator" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}
## svc-cat
data "helm_repository" "svc-cat" {
  name = "svc-cat"
  url  = "https://svc-catalog-charts.storage.googleapis.com"
}
## jetstack (cert-manager)
data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}