resource oci_core_network_security_group waf_nsg {
  compartment_id = var.lb_compartment_ocid
  display_name   = "WAF-Allow-NSG"
  freeform_tags  = local.common_tags
  vcn_id         = oci_core_virtual_network.mushop_lb_vcn[0].id
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_1 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.157.18.0/24"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_2 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.157.19.0/24"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_3 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "205.147.88.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_4 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.69.118.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_5 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "198.181.48.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_6 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "199.195.6.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_7 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.96.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_8 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.96.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_9 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.8.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_10 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.4.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_11 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.128.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_12 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.32.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_13 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.16.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_14 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.8.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_15 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.240.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_16 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.128.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_17 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.0.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_18 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.146.14.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_19 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.146.13.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_20 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.146.12.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_21 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.138.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_22 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.128.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_23 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.12.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_24 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.34.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_25 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.84.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_26 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.80.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_27 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.64.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_28 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.0.0/18"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_29 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.12.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_30 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.10.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_31 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.48.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_32 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.32.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_33 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.24.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_34 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.232.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_35 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.224.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_36 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.192.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_37 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.176.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_38 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.144.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_39 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.120.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_40 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.96.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_41 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.64.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_42 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.48.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_43 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.16.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_44 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.213.4.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_45 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.213.2.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_46 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "129.213.0.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_47 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.208.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_48 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.192.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_49 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.128.0/18"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_50 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.192.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_51 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.160.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_52 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.104.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_53 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.96.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_54 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.64.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_55 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.40.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_56 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.0.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_57 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.64.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_58 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.0.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_59 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.0.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_60 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.28.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_61 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.72.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_62 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.44.0/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_63 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.40.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_64 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.32.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_65 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.8.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_66 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.32.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_67 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.80.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_68 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "147.154.224.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_69 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.24.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_70 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.22.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_71 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.224.0/19"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_72 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.208.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_73 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.80.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_74 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "138.1.16.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_75 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.64.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_76 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.56.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_77 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "132.145.4.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_78 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "132.145.2.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_79 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "132.145.0.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_80 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.116.0/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_81 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "130.35.112.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_82 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.16.0/20"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_83 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.24.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_84 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.40.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_85 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.96.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_86 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.172.0/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_87 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.168.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_88 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.160.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_89 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.48.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_90 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.4.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_91 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.30.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_92 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.76.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_93 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.180.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_94 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.178.0/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_95 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.60.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_96 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.56.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_97 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.16.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_98 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.36.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_99 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.88.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_100 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.152.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_101 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "192.29.144.0/21"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_102 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.204.20.128/25"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_103 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "140.91.38.0/23"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource oci_core_network_security_group_security_rule waf_nsg_rule_104 {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.waf_nsg.id
  protocol                  = "6"
  source                    = "134.70.92.0/22"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}
