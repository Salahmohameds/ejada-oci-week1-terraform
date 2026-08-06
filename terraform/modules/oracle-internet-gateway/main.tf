resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name
  enabled        = var.enabled

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  # Intentionally no route_table_id: default route belongs on the subnet RT
  # (0.0.0.0/0 → this IGW), not as a gateway-level RT attachment.
}
