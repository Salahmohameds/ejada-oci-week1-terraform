# Display names and shared tags — module inputs come from var.* / locals.

locals {
  name_prefix = var.name_prefix

  freeform_tags = {
    Project   = var.project_tag
    Lab       = var.lab_tag
    ManagedBy = "Terraform"
  }

  vcn_display_name            = coalesce(var.vcn_display_name != "" ? var.vcn_display_name : null, "${local.name_prefix}-vcn")
  igw_display_name            = coalesce(var.igw_display_name != "" ? var.igw_display_name : null, "${local.name_prefix}-igw")
  nat_display_name            = coalesce(var.nat_display_name != "" ? var.nat_display_name : null, "${local.name_prefix}-nat")
  public_rt_display_name      = coalesce(var.public_rt_display_name != "" ? var.public_rt_display_name : null, "${local.name_prefix}-public-rt")
  private_rt_display_name     = coalesce(var.private_rt_display_name != "" ? var.private_rt_display_name : null, "${local.name_prefix}-private-rt")
  public_sl_display_name      = coalesce(var.public_sl_display_name != "" ? var.public_sl_display_name : null, "${local.name_prefix}-public-sl")
  private_sl_display_name     = coalesce(var.private_sl_display_name != "" ? var.private_sl_display_name : null, "${local.name_prefix}-private-sl")
  public_subnet_display_name  = coalesce(var.public_subnet_display_name != "" ? var.public_subnet_display_name : null, "${local.name_prefix}-public-subnet")
  private_subnet_display_name = coalesce(var.private_subnet_display_name != "" ? var.private_subnet_display_name : null, "${local.name_prefix}-private-subnet")
  sgw_display_name            = coalesce(var.sgw_display_name != "" ? var.sgw_display_name : null, "${local.name_prefix}-sgw")
  nsg_lb_display_name         = coalesce(var.nsg_lb_display_name != "" ? var.nsg_lb_display_name : null, "${local.name_prefix}-nsg-lb")
  nsg_app_display_name        = coalesce(var.nsg_app_display_name != "" ? var.nsg_app_display_name : null, "${local.name_prefix}-nsg-app")
  nsg_mt_display_name         = coalesce(var.nsg_mt_display_name != "" ? var.nsg_mt_display_name : null, "${local.name_prefix}-nsg-mt")
  bastion_name                = coalesce(var.bastion_name != "" ? var.bastion_name : null, "${local.name_prefix}-bastion")
  app_instance_display_name   = coalesce(var.app_instance_display_name != "" ? var.app_instance_display_name : null, "${local.name_prefix}-private-vm")
  jump_instance_display_name  = coalesce(var.jump_instance_display_name != "" ? var.jump_instance_display_name : null, "${local.name_prefix}-jump")
  fss_display_name            = coalesce(var.fss_display_name != "" ? var.fss_display_name : null, "${local.name_prefix}-fss")
  mount_target_display_name   = coalesce(var.mount_target_display_name != "" ? var.mount_target_display_name : null, "${local.name_prefix}-mt")
  lb_display_name             = coalesce(var.lb_display_name != "" ? var.lb_display_name : null, "${local.name_prefix}-lb")

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name
  image_id            = data.oci_core_images.oracle_linux.images[0].id

  fss_export_source_cidr = coalesce(var.fss_export_source_cidr != "" ? var.fss_export_source_cidr : null, var.vcn_cidr)
  bastion_client_cidrs   = length(var.bastion_client_cidr_block_allow_list) > 0 ? var.bastion_client_cidr_block_allow_list : [var.allowed_ssh_cidr]

  # Single map driving module.compute's for_each — add/remove entries here instead of
  # adding new module calls. "jump" is only present when enable_jump = true.
  compute_instances = merge(
    {
      app = {
        display_name            = local.app_instance_display_name
        shape                   = var.instance_shape
        ocpus                   = var.instance_ocpus
        memory_in_gbs           = var.instance_memory_in_gbs
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
        subnet_id               = module.network.private_subnet_id
        assign_public_ip        = false
        hostname_label          = var.app_hostname_label
        nsg_ids                 = module.network.nsg_app_ids
        ssh_public_key          = var.ssh_public_key
        cloud_init = {
          mount_target_ip  = coalesce(module.storage.mount_target_ip, "")
          fss_export_path  = var.fss_export_path
          app_mount_path   = var.app_mount_path
          app_port         = var.app_port
          index_html_body  = var.app_index_html_body
          enable_fss_mount = var.enable_fss
        }
      }
    },
    var.enable_jump ? {
      jump = {
        display_name            = local.jump_instance_display_name
        shape                   = var.instance_shape
        ocpus                   = var.jump_ocpus
        memory_in_gbs           = var.jump_memory_in_gbs
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
        subnet_id               = module.network.public_subnet_id
        assign_public_ip        = true
        hostname_label          = var.jump_hostname_label
        nsg_ids                 = []
        ssh_public_key          = var.ssh_public_key
        cloud_init              = null
      }
    } : {}
  )
}
