# File Storage: FS + mount target + export (related group module).

module "storage" {
  source = "./modules/storage"

  compartment_ocid            = var.compartment_ocid
  availability_domain         = local.availability_domain
  private_subnet_id           = module.network.private_subnet_id
  nsg_ids                     = module.network.nsg_mt_ids
  freeform_tags               = local.freeform_tags
  enable_fss                  = var.enable_fss
  fss_display_name            = local.fss_display_name
  mount_target_display_name   = local.mount_target_display_name
  mount_target_hostname_label = var.mount_target_hostname_label
  fss_export_path             = var.fss_export_path
  fss_export_source_cidr      = local.fss_export_source_cidr
  fss_export_access           = var.fss_export_access
}
