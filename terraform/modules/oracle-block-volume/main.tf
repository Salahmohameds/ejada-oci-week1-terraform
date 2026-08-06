# Block volume + optional attach (paravirtualized from the stack).

resource "oci_core_volume" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.display_name
  size_in_gbs         = var.size_in_gbs
  vpus_per_gb         = var.vpus_per_gb

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_volume_attachment" "this" {
  count = var.attach_to_instance ? 1 : 0

  attachment_type = var.attachment_type
  instance_id     = var.instance_id
  volume_id       = oci_core_volume.this.id

  display_name = coalesce(var.attachment_display_name, "${var.display_name}-attach")
  is_read_only = var.is_read_only
  is_shareable = var.is_shareable
  device       = var.device
}
