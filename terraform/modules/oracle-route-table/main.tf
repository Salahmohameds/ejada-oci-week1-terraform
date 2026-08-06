# Route table; rules list may be empty (private-subnet style).

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  dynamic "route_rules" {
    for_each = var.route_rules
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
      description       = try(route_rules.value.description, null)
    }
  }
}
