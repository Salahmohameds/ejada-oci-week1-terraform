# Private app (+ optional jump) with cloud-init for FSS mount + HTTP.

module "compute" {
  source = "./modules/compute"

  compartment_ocid           = var.compartment_ocid
  availability_domain        = local.availability_domain
  image_id                   = local.image_id
  private_subnet_id          = module.network.private_subnet_id
  public_subnet_id           = module.network.public_subnet_id
  nsg_app_ids                = module.network.nsg_app_ids
  freeform_tags              = local.freeform_tags
  ssh_public_key             = var.ssh_public_key
  instance_shape             = var.instance_shape
  instance_ocpus             = var.instance_ocpus
  instance_memory_in_gbs     = var.instance_memory_in_gbs
  boot_volume_size_in_gbs    = var.boot_volume_size_in_gbs
  app_instance_display_name  = local.app_instance_display_name
  app_hostname_label         = var.app_hostname_label
  app_port                   = var.app_port
  app_mount_path             = var.app_mount_path
  app_index_html_body        = var.app_index_html_body
  enable_fss                 = var.enable_fss
  fss_export_path            = var.fss_export_path
  mount_target_ip            = coalesce(module.storage.mount_target_ip, "")
  enable_jump                = var.enable_jump
  jump_instance_display_name = local.jump_instance_display_name
  jump_hostname_label        = var.jump_hostname_label
  jump_ocpus                 = var.jump_ocpus
  jump_memory_in_gbs         = var.jump_memory_in_gbs

  # cloud-init needs export ready when FSS is enabled.
  depends_on = [module.storage]
}
