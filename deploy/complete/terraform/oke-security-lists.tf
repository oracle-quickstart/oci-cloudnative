# Copyright (c) 2020, 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_security_list" "oke_nodes_security_list" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-nodes-wkr-seclist-${local.app_name_normalized}-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  # Ingresses
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    source      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.all_protocols
    stateless   = false
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    source      = lookup(var.network_cidrs, (var.cluster_workers_visibility == "Private") ? "VCN-CIDR" : "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.ssh_port_number
      min = local.ssh_port_number
    }
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    source      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false
  }
  ingress_security_rules {
    description = "Path discovery"
    source      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol_number
    stateless   = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  # Egresses
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.k8s_api_endpoint_port_number
      min = local.k8s_api_endpoint_port_number
    }
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.k8s_worker_to_control_plane_port_number
      min = local.k8s_worker_to_control_plane_port_number
    }
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = lookup(var.network_cidrs, "ENDPOINT-SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_security_list" "oke_lb_security_list" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-lb-seclist-${local.app_name_normalized}-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_security_list" "oke_endpoint_security_list" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "oke-k8s-api-endpoint-seclist-${local.app_name_normalized}-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  # Ingresses

  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    source      = lookup(var.network_cidrs, (var.cluster_endpoint_visibility == "Private") ? "VCN-CIDR" : "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.k8s_api_endpoint_port_number
      min = local.k8s_api_endpoint_port_number
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    source      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.k8s_api_endpoint_port_number
      min = local.k8s_api_endpoint_port_number
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    source      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.k8s_worker_to_control_plane_port_number
      min = local.k8s_worker_to_control_plane_port_number
    }
  }
  ingress_security_rules {
    description = "Path discovery"
    source      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.icmp_protocol_number
    stateless   = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  # Egresses

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.tcp_protocol_number
    stateless        = false
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = lookup(var.network_cidrs, "SUBNET-REGIONAL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.icmp_protocol_number
    stateless        = false

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_core_security_list" "apigw_fn_security_list" {
  compartment_id = local.oke_compartment_ocid
  display_name   = "apigw-fn-seclist-${local.app_name_normalized}-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.oke_vcn[0].id

  # Ingresses

  ingress_security_rules {
    description = "Allow API Gateway to receive requests"
    source      = lookup(var.network_cidrs, "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }

  # Egresses

  egress_security_rules {
    description      = "Allow API Gateway to forward requests to Functions via service conduit"
    destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

locals {
  http_port_number                        = "80"
  https_port_number                       = "443"
  k8s_api_endpoint_port_number            = "6443"
  k8s_worker_to_control_plane_port_number = "12250"
  ssh_port_number                         = "22"
  tcp_protocol_number                     = "6"
  icmp_protocol_number                    = "1"
  all_protocols                           = "all"
}