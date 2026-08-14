# Private app (+ optional jump). Cloud-init mounts FSS and serves HTTP.

locals {
  app_user_data = base64encode(templatefile("${path.module}/cloud-init/app.yaml.tftpl", {
    mount_target_ip  = var.mount_target_ip
    fss_export_path  = var.fss_export_path
    app_mount_path   = var.app_mount_path
    app_port         = tostring(var.app_port)
    index_html_body  = var.app_index_html_body
    enable_fss_mount = var.enable_fss ? "true" : "false"
  }))
}

resource "oci_core_instance" "app" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = var.app_instance_display_name
  shape               = var.instance_shape
  freeform_tags       = var.freeform_tags

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.private_subnet_id
    assign_public_ip = false
    hostname_label   = var.app_hostname_label
    display_name     = "${var.app_instance_display_name}-vnic"
    nsg_ids          = var.nsg_app_ids
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = local.app_user_data
  }

  preserve_boot_volume = false
}

resource "oci_core_instance" "jump" {
  count = var.enable_jump ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = var.jump_instance_display_name
  shape               = var.instance_shape
  freeform_tags       = var.freeform_tags

  shape_config {
    ocpus         = var.jump_ocpus
    memory_in_gbs = var.jump_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.public_subnet_id
    assign_public_ip = true
    hostname_label   = var.jump_hostname_label
    display_name     = "${var.jump_instance_display_name}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = false
}
