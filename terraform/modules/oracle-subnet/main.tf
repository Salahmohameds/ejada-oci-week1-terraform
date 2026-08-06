# Subnet with RT + SL; prohibit_public_ip_on_vnic=true marks private subnets.

resource "oci_core_subnet" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name
  cidr_block     = var.cidr_block

  route_table_id             = var.route_table_id
  security_list_ids          = var.security_list_ids
  prohibit_public_ip_on_vnic = var.prohibit_public_ip_on_vnic

  dns_label           = var.dns_label != "" ? var.dns_label : null
  availability_domain = var.availability_domain
  dhcp_options_id     = var.dhcp_options_id

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
