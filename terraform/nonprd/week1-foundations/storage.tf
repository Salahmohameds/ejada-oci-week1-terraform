# Block volume always attached (same AD as the instance). FSS is optional.

module "block_volume" {
  source = "../../modules/oracle-block-volume"

  compartment_id      = var.compartment_ocid
  display_name        = "${local.name_prefix}-block-vol"
  availability_domain = module.instance.availability_domain
  size_in_gbs         = var.block_volume_size_in_gbs
  vpus_per_gb         = var.block_volume_vpus_per_gb

  attach_to_instance      = true
  instance_id             = module.instance.id
  attachment_type         = "paravirtualized"
  attachment_display_name = "${local.name_prefix}-block-vol-attach"
  freeform_tags           = local.freeform_tags
}

# Default off: shared tenancies often exhaust mount-target-count.
module "file_storage" {
  count  = var.enable_file_storage ? 1 : 0
  source = "../../modules/oracle-file-system"

  compartment_id            = var.compartment_ocid
  availability_domain       = local.availability_domain
  subnet_id                 = module.public_subnet.id
  file_system_display_name  = "${local.name_prefix}-fss"
  mount_target_display_name = "${local.name_prefix}-mt"
  export_path               = var.fss_export_path
  export_source_cidr        = var.fss_export_source_cidr
  freeform_tags             = local.freeform_tags
}
