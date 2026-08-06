# FS + mount target + export. MT creation fails if mount-target-count is exhausted.

resource "oci_file_storage_file_system" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.file_system_display_name

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_file_storage_mount_target" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  subnet_id           = var.subnet_id
  display_name        = var.mount_target_display_name

  nsg_ids        = length(var.nsg_ids) > 0 ? var.nsg_ids : null
  hostname_label = var.hostname_label

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_file_storage_export" "this" {
  export_set_id  = oci_file_storage_mount_target.this.export_set_id
  file_system_id = oci_file_storage_file_system.this.id
  path           = var.export_path

  export_options {
    source                         = var.export_source_cidr
    access                         = var.export_access
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}
