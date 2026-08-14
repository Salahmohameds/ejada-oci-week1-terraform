# Network edge: VCN + IGW + NAT + SGW + RTs + SLs + NSGs + subnets.

module "network" {
  source = "./modules/network"

  compartment_ocid            = var.compartment_ocid
  freeform_tags               = local.freeform_tags
  vcn_cidr                    = var.vcn_cidr
  public_subnet_cidr          = var.public_subnet_cidr
  private_subnet_cidr         = var.private_subnet_cidr
  vcn_dns_label               = var.vcn_dns_label
  public_subnet_dns_label     = var.public_subnet_dns_label
  private_subnet_dns_label    = var.private_subnet_dns_label
  vcn_display_name            = local.vcn_display_name
  igw_display_name            = local.igw_display_name
  nat_display_name            = local.nat_display_name
  sgw_display_name            = local.sgw_display_name
  public_rt_display_name      = local.public_rt_display_name
  private_rt_display_name     = local.private_rt_display_name
  public_sl_display_name      = local.public_sl_display_name
  private_sl_display_name     = local.private_sl_display_name
  public_subnet_display_name  = local.public_subnet_display_name
  private_subnet_display_name = local.private_subnet_display_name
  nsg_lb_display_name         = local.nsg_lb_display_name
  nsg_app_display_name        = local.nsg_app_display_name
  nsg_mt_display_name         = local.nsg_mt_display_name
  enable_service_gateway      = var.enable_service_gateway
  enable_nsgs                 = var.enable_nsgs
  enable_fss                  = var.enable_fss
  allowed_ssh_cidr            = var.allowed_ssh_cidr
  app_port                    = var.app_port
  enable_https_ingress        = var.enable_https_ingress
}
