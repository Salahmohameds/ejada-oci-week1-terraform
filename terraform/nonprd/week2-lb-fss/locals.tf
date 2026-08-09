locals {
  name_prefix = var.name_prefix

  freeform_tags = {
    Project   = var.project_tag
    Lab       = var.lab_tag
    ManagedBy = "Terraform"
  }

  # Display names — var override or derived prefix.
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

  image_id = data.oci_core_images.oracle_linux.images[0].id

  # Export allow for NFS clients within the VCN unless overridden.
  fss_export_source_cidr = coalesce(var.fss_export_source_cidr != "" ? var.fss_export_source_cidr : null, var.vcn_cidr)

  # Bastion client allow-list: explicit list or fall back to allowed_ssh_cidr.
  bastion_client_cidrs = length(var.bastion_client_cidr_block_allow_list) > 0 ? var.bastion_client_cidr_block_allow_list : [var.allowed_ssh_cidr]

  # All <region> Services in Oracle Services Network (for SGW + private RT).
  osn_service = try(data.oci_core_services.all_osn.services[0], null)

  # NSG OCIDs for attachments (empty list when disabled).
  nsg_lb_ids  = var.enable_nsgs ? [oci_core_network_security_group.lb[0].id] : []
  nsg_app_ids = var.enable_nsgs ? [oci_core_network_security_group.app[0].id] : []
  nsg_mt_ids  = var.enable_nsgs && var.enable_fss ? [oci_core_network_security_group.mt[0].id] : []

  # MT IP when FSS is enabled (private IP data source).
  mount_target_ip = var.enable_fss ? data.oci_core_private_ip.mount_target[0].ip_address : ""

  # cloud-init renders mount + HTTP systemd unit on the private app VM.
  app_user_data = base64encode(templatefile("${path.module}/cloud-init/app.yaml.tftpl", {
    mount_target_ip  = local.mount_target_ip
    fss_export_path  = var.fss_export_path
    app_mount_path   = var.app_mount_path
    app_port         = tostring(var.app_port)
    index_html_body  = var.app_index_html_body
    enable_fss_mount = var.enable_fss ? "true" : "false"
  }))
}
