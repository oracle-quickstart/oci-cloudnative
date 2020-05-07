# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create namespace mushop-utilities for supporting services
resource "kubernetes_namespace" "mushop-utilities_namespace" {
  metadata {
    name = "mushop-utilities"
  }
  depends_on = [oci_containerengine_node_pool.oke-mushop_node_pool]
}

# MuShop Utilities helm charts

## https://github.com/helm/charts/blob/master/stable/prometheus/README.md
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus"
  version    = "11.1.5"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = false

  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}

## # https://github.com/helm/charts/blob/master/stable/grafana/README.md
resource "helm_release" "grafana" {
  name       = "mushop-utils-grafana" # mushop-utils included to be backwards compatible to the docs and setup chart install
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "grafana"
  version    = "5.0.20"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = false

  values = [
    file("${path.module}/chart-values/grafana.yaml"),
  ]

  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}

## https://github.com/helm/charts/blob/master/stable/metrics-server/README.md
resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "metrics-server"
  version    = "2.11.1"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = false

  values = [
    file("${path.module}/chart-values/metrics-server.yaml"),
  ]

  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}

## https://kubernetes.github.io/ingress-nginx/
resource "helm_release" "ingress-nginx" {
  name       = "mushop-utils-ingress-nginx"
  repository = data.helm_repository.ingress-nginx.metadata[0].name
  chart      = "ingress-nginx/ingress-nginx"
  version    = "2.0.2"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = true

  timeout = 600 # workaround to wait the node be active for other charts
}

## https://github.com/kubernetes-sigs/service-catalog/blob/master/charts/catalog/README.md
resource "helm_release" "svc-cat" {
  name       = "svc-cat"
  repository = data.helm_repository.svc-cat.metadata[0].name
  chart      = "catalog"
  version    = "0.3.0-beta.2"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = false

  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}

## https://github.com/jetstack/cert-manager/blob/master/README.md
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart      = "cert-manager"
  version    = "0.15.0-alpha.3"
  namespace  = kubernetes_namespace.mushop-utilities_namespace.id
  wait       = false

  set {
    name  = "installCRDs"
    value = true
  }

  depends_on = [helm_release.ingress-nginx] # Ugly workaround because of the oci pvc provisioner not be able to wait for the node be active and retry.
}