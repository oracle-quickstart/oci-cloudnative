resource "oci_core_virtual_network" "mushopVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushopVCN"
  dns_label      = "mushopvcn"
}

resource "oci_core_subnet" "mushopSubnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
  cidr_block          = "10.1.20.0/24"
  display_name        = "mushopSubnet"
  dns_label           = "mushopsubnet"
  security_list_ids   = ["${oci_core_security_list.mushopSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.mushopVCN.id}"
  route_table_id      = "${oci_core_route_table.mushopRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.mushopVCN.default_dhcp_options_id}"
}


resource "oci_core_internet_gateway" "mushopIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "mushopIG"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
}



resource "oci_core_route_table" "mushopRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.mushopVCN.id}"
  display_name   = "mushopRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.mushopIG.id}"
  }
}
