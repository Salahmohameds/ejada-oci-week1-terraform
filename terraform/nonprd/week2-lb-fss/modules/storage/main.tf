# File Storage building block: file system + mount target + export.

resource "oci_file_storage_file_system" "this" {
  count = var.enable_fss ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = var.fss_display_name
  freeform_tags       = var.freeform_tags
}

resource "oci_file_storage_mount_target" "this" {
  count = var.enable_fss ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  subnet_id           = var.private_subnet_id
  display_name        = var.mount_target_display_name
  hostname_label      = var.mount_target_hostname_label
  nsg_ids             = var.nsg_ids
  freeform_tags       = var.freeform_tags
}

resource "oci_file_storage_export" "this" {
  count = var.enable_fss ? 1 : 0

  export_set_id  = oci_file_storage_mount_target.this[0].export_set_id
  file_system_id = oci_file_storage_file_system.this[0].id
  path           = var.fss_export_path

  export_options {
    source                         = var.fss_export_source_cidr
    access                         = var.fss_export_access
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}

data "oci_core_private_ip" "mount_target" {
  count = var.enable_fss ? 1 : 0

  private_ip_id = oci_file_storage_mount_target.this[0].private_ip_ids[0]
}
