# Three related-group subnets via module.subnet (subnet + RT + SL + optional logs).
# VCN / gateways / shared log group come from module.network.
# Keys must stay lb / workers / pods so module.oke can look them up.
#
# lb      — public (IGW). API endpoint + Kubernetes Service LBs need a public IP.
# workers — private (NAT). Managed node pool VNICs.
# pods    — private (NAT), /18. VCN-native CNI assigns each pod a VCN IP; a /24
#           is too small at max_pods_per_node (31) even with a one-node pool.
# logs    — enabled on lb only. That is the north-south path (API + Service LB),
#           and Enable Logs can be shown in Stage A before the cluster exists.

module "subnet" {
  source   = "./modules/subnet"
  for_each = local.subnets

  compartment_ocid           = var.compartment_ocid
  vcn_id                     = module.network.vcn_id
  display_name               = each.value.display_name
  cidr_block                 = each.value.cidr
  dns_label                  = each.value.dns_label
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  default_route_gateway_id   = each.value.default_route_gateway_id
  default_route_description  = each.value.default_route_description
  extra_route_rules          = each.value.extra_route_rules
  ingress_security_rules     = each.value.ingress_security_rules
  egress_security_rules      = each.value.egress_security_rules
  enable_logs                = each.value.enable_logs
  create_log_group           = false
  log_group_id               = module.network.log_group_id
  log_retention_duration     = var.log_retention_duration
  flow_log_sampling_rate     = var.flow_log_sampling_rate
  freeform_tags              = local.freeform_tags
  defined_tags               = local.defined_tags
}
