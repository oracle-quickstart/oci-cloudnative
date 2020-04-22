resource "oci_containerengine_cluster" "oke-mushop_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.k8s_version
  name               = "${var.cluster_name}-${random_string.deploy_id.result}"
  vcn_id             = oci_core_virtual_network.oke-mushop_vcn.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.oke-mushop_lb_subnet.id]
    add_ons {
            is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
            is_tiller_enabled = true
        }
    admission_controller_options {
            is_pod_security_policy_enabled = false
        }
  }
}

resource "oci_containerengine_node_pool" "oke-mushop_node_pool" {
  cluster_id          = oci_containerengine_cluster.oke-mushop_cluster.id
  compartment_id      = var.compartment_ocid
  kubernetes_version  = var.k8s_version
  name                = var.node_pool_name
  node_shape          = var.node_pool_shape
  ssh_public_key      = var.public_ssh_key
  
  node_config_details {
        dynamic "placement_configs" {
            for_each = data.oci_identity_availability_domains.ADs.availability_domains

            content {
                availability_domain = placement_configs.value.name
                subnet_id           = oci_core_subnet.oke-mushop_subnet.id
            }
        }
        size = var.num_pool_workers
    }


  node_source_details {
    source_type   = "IMAGE"
    image_id = lookup(data.oci_core_images.node_pool_images.images[0], "id")
  }
  
  initial_node_labels {
    key   = "name"
    value = var.node_pool_name
  }
}

## Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "kubeconfig" {
  content = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
	filename = "generated/kubeconfig"
}