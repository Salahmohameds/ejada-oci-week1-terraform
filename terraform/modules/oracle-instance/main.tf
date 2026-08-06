# Compute instance + image lookup; primary VNIC id is exported for reserved IP attach.

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = coalesce(var.image_shape, var.shape)
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.display_name
  shape               = var.shape

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.hostname_label
    display_name     = "${var.display_name}-vnic"
  }

  source_details {
    source_type             = var.source_type
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  dynamic "shape_config" {
    for_each = var.shape_config != null ? [var.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  metadata = merge(
    {
      ssh_authorized_keys = var.ssh_public_keys
    },
    var.user_data != null ? { user_data = base64encode(var.user_data) } : {}
  )

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  preserve_boot_volume = false
}

# Needed so callers can attach a RESERVED public IP to the primary private IP.
data "oci_core_vnic_attachments" "primary" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.this.id
}

locals {
  image_id = data.oci_core_images.oracle_linux.images[0].id

  primary_vnic_attachment = try(
    [
      for a in data.oci_core_vnic_attachments.primary.vnic_attachments : a
      if try(a.is_primary, false)
    ][0],
    data.oci_core_vnic_attachments.primary.vnic_attachments[0]
  )
}
