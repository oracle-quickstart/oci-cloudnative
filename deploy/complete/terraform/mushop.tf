# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create namespace mushop for the mushop microservices
resource "kubernetes_namespace" "mushop_namespace" {
  metadata {
    name = "mushop"
  }
  depends_on = [oci_containerengine_node_pool.oke-mushop_node_pool]
}

resource "kubernetes_namespace" "mushop-utilities_namespace" {
  metadata {
    name = "mushop-utilities"
  }
  depends_on = [oci_containerengine_node_pool.oke-mushop_node_pool]
}

# Deploy setup chart with mushop utilities
# resource "helm_release" "mushop-utility" {
#   name              = "mushop-utility"
#   chart             = "../helm-chart/setup"
#   namespace         = kubernetes_namespace.mushop-utilities_namespace.id
#   dependency_update = true
#   wait              = true
# }