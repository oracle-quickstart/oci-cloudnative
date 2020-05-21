# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_containerengine_cluster" "oke_mushop_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "${var.cluster_name}-${random_string.deploy_id.result}"
  vcn_id             = oci_core_virtual_network.oke_mushop_vcn.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.oke_mushop_lb_subnet.id]
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false # Default is false, left here for reference
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
  }
}

resource "oci_containerengine_node_pool" "oke_mushop_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_mushop_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = var.node_pool_name
  node_shape         = var.node_pool_shape
  ssh_public_key     = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.public_ssh_key

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.oke_mushop_subnet.id
      }
    }
    size = var.num_pool_workers
  }


  node_source_details {
    source_type = "IMAGE"
    image_id    = lookup(data.oci_core_images.node_pool_images.images[0], "id")
  }

  initial_node_labels {
    key   = "name"
    value = var.node_pool_name
  }
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "generated/kubeconfig"
}

# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm   = "RSA"
  rsa_bits = 2048
}