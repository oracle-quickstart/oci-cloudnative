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

# Deploy mushop chart
resource "helm_release" "mushop" {
  name      = "mushop"
  chart     = "../helm-chart/mushop"
  namespace = kubernetes_namespace.mushop_namespace.id
  wait      = false

  values = [
    file("${path.module}/../helm-chart/mushop/values-mock.yaml"),
  ]

  depends_on = [helm_release.nginx-ingress] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}
