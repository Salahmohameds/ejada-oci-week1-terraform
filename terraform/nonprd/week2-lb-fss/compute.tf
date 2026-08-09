# Private app instance (always). Optional public jump host via enable_jump.

resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  display_name        = local.app_instance_display_name
  shape               = var.instance_shape
  freeform_tags       = local.freeform_tags

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    hostname_label   = var.app_hostname_label
    display_name     = "${local.app_instance_display_name}-vnic"
    nsg_ids          = local.nsg_app_ids
  }

  source_details {
    source_type             = "image"
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = local.app_user_data
  }

  # cloud-init needs MT IP when FSS is enabled.
  depends_on = [
    oci_file_storage_export.app,
  ]

  preserve_boot_volume = false
}

resource "oci_core_instance" "jump" {
  count = var.enable_jump ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  display_name        = local.jump_instance_display_name
  shape               = var.instance_shape
  freeform_tags       = local.freeform_tags

  shape_config {
    ocpus         = var.jump_ocpus
    memory_in_gbs = var.jump_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    hostname_label   = var.jump_hostname_label
    display_name     = "${local.jump_instance_display_name}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}
