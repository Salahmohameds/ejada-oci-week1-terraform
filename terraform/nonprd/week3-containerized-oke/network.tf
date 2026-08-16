# VCN core related-group: module.network (VCN + IGW + NAT + SGW + shared log group).
# Subnets live in subnets.tf (module.subnet). Cluster lives in oke.tf.
# No count on this module — Stage A still needs the VCN even when enable_oke is false.

module "network" {
  source = "./modules/network"

  compartment_ocid       = var.compartment_ocid
  vcn_display_name       = local.vcn_display_name
  vcn_cidr               = var.vcn_cidr
  vcn_dns_label          = var.vcn_dns_label
  igw_display_name       = local.igw_display_name
  nat_display_name       = local.nat_display_name
  sgw_display_name       = local.sgw_display_name
  enable_service_gateway = var.enable_service_gateway
  enable_log_group       = local.any_subnet_logs
  log_group_display_name = local.log_group_display_name
  freeform_tags          = local.freeform_tags
  defined_tags           = local.defined_tags
}

# Same resource types as the former root oci_* (empty state today; a re-apply
# with leftover state would move instead of replace).
moved {
  from = oci_core_vcn.this
  to   = module.network.oci_core_vcn.this
}

moved {
  from = oci_core_internet_gateway.this
  to   = module.network.oci_core_internet_gateway.this
}

moved {
  from = oci_core_nat_gateway.this
  to   = module.network.oci_core_nat_gateway.this
}

moved {
  from = oci_core_service_gateway.this
  to   = module.network.oci_core_service_gateway.this
}

moved {
  from = oci_logging_log_group.vcn_flow
  to   = module.network.oci_logging_log_group.vcn_flow
}

moved {
  from = data.oci_core_services.all_osn
  to   = module.network.data.oci_core_services.all_osn
}
