# File Storage: file system + mount target in private subnet + export.

resource "oci_file_storage_file_system" "app" {
  count = var.enable_fss ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  display_name        = local.fss_display_name
  freeform_tags       = local.freeform_tags
}

resource "oci_file_storage_mount_target" "app" {
  count = var.enable_fss ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  subnet_id           = oci_core_subnet.private.id
  display_name        = local.mount_target_display_name
  hostname_label      = var.mount_target_hostname_label
  nsg_ids             = local.nsg_mt_ids
  freeform_tags       = local.freeform_tags
}

resource "oci_file_storage_export" "app" {
  count = var.enable_fss ? 1 : 0

  export_set_id  = oci_file_storage_mount_target.app[0].export_set_id
  file_system_id = oci_file_storage_file_system.app[0].id
  path           = var.fss_export_path

  export_options {
    source                         = local.fss_export_source_cidr
    access                         = var.fss_export_access
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}
