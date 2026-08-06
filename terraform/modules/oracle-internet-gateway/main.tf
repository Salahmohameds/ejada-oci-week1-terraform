resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name
  enabled        = var.enabled

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  # IMPORTANT (OCI footgun):
  # Do NOT set route_table_id on the internet gateway for basic public subnet designs.
  # Gateway-level route tables are for advanced gateway routing scenarios only.
  # Public internet egress is configured on the *subnet* route table
  # (0.0.0.0/0 → this IGW), not by attaching an RT to the IGW itself.
}
