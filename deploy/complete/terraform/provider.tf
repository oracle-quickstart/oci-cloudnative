# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}

provider "kubernetes" {
  load_config_file = "false"
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  host = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["server"]
  exec {
    api_version = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["apiVersion"]
    args = [yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][0],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][1],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][2],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][3],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][4],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][5],
            yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][6]]
    command = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["command"]
  }
}

provider "helm" {
  kubernetes {
    load_config_file = "false"
    cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
    host = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["clusters"][0]["cluster"]["server"]
    exec {
      api_version = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["apiVersion"]
      args = [yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][0],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][1],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][2],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][3],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][4],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][5],
              yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["args"][6]]
      command = yamldecode(data.oci_containerengine_cluster_kube_config.kube_config.content)["users"][0]["user"]["exec"]["command"]
    }
  }
}