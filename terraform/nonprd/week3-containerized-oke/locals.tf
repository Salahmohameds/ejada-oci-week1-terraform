# Display names, tags, SL/RT rule payloads, and the subnet map passed to
# module.subnet. Resource arguments read var.* / local.* (w3-* values live in tfvars).

locals {
  name_prefix = var.name_prefix

  freeform_tags = {
    Project   = var.project_tag
    Lab       = var.lab_tag
    ManagedBy = "Terraform"
  }

  defined_tags = var.defined_tags

  vcn_display_name             = coalesce(var.vcn_display_name != "" ? var.vcn_display_name : null, "${local.name_prefix}-vcn")
  igw_display_name             = coalesce(var.igw_display_name != "" ? var.igw_display_name : null, "${local.name_prefix}-igw")
  nat_display_name             = coalesce(var.nat_display_name != "" ? var.nat_display_name : null, "${local.name_prefix}-nat")
  sgw_display_name             = coalesce(var.sgw_display_name != "" ? var.sgw_display_name : null, "${local.name_prefix}-sgw")
  log_group_display_name       = coalesce(var.log_group_display_name != "" ? var.log_group_display_name : null, "${local.name_prefix}-vcn-logs")
  oke_cluster_display_name     = coalesce(var.oke_cluster_display_name != "" ? var.oke_cluster_display_name : null, "${local.name_prefix}-oke")
  oke_node_pool_display_name   = coalesce(var.oke_node_pool_display_name != "" ? var.oke_node_pool_display_name : null, "${local.name_prefix}-np")
  nsg_oke_api_display_name     = coalesce(var.nsg_oke_api_display_name != "" ? var.nsg_oke_api_display_name : null, "${local.name_prefix}-nsg-oke-api")
  nsg_oke_workers_display_name = coalesce(var.nsg_oke_workers_display_name != "" ? var.nsg_oke_workers_display_name : null, "${local.name_prefix}-nsg-oke-workers")
  nsg_oke_pods_display_name    = coalesce(var.nsg_oke_pods_display_name != "" ? var.nsg_oke_pods_display_name : null, "${local.name_prefix}-nsg-oke-pods")

  availability_domain = try(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name, null)

  kubernetes_versions = try(data.oci_containerengine_cluster_option.all[0].kubernetes_versions, [])
  kubernetes_version  = var.kubernetes_version != "" ? var.kubernetes_version : try(reverse(sort(local.kubernetes_versions))[0], "")

  oke_node_image_arch_is_arm = strcontains(upper(var.oke_node_shape), "A1")
  oke_k8s_ver_numeric        = replace(local.kubernetes_version, "v", "")

  oke_node_images = [
    for s in coalesce(try(data.oci_containerengine_node_pool_option.all[0].sources, null), []) : s.image_id
    if(
      length(regexall("OKE", s.source_name)) > 0 &&
      (local.oke_k8s_ver_numeric == "" || length(regexall(replace(local.oke_k8s_ver_numeric, ".", "\\."), s.source_name)) > 0) &&
      (local.oke_node_image_arch_is_arm ? length(regexall("aarch64", s.source_name)) > 0 : length(regexall("aarch64", s.source_name)) == 0)
    )
  ]

  oke_node_image_id = var.oke_node_image_id != "" ? var.oke_node_image_id : try(local.oke_node_images[0], "")

  any_subnet_logs = anytrue([for s in var.subnets : s.enable_logs])

  gateway_ids = {
    igw = module.network.internet_gateway_id
    nat = module.network.nat_gateway_id
  }

  lb_cidr     = var.subnets["lb"].cidr
  worker_cidr = var.subnets["workers"].cidr
  pod_cidr    = var.subnets["pods"].cidr

  common_icmp_ingress = [
    { protocol = "1", source = "0.0.0.0/0", description = "ICMP type 3 code 4 (PMTU)", icmp_type = 3, icmp_code = 4 },
    { protocol = "1", source = var.vcn_cidr, description = "ICMP type 3 within VCN", icmp_type = 3 },
  ]

  default_egress = [
    { protocol = "all", destination = "0.0.0.0/0", description = "Allow all egress" },
  ]

  lb_https_ingress = var.enable_https_ingress ? [
    { protocol = "6", source = "0.0.0.0/0", description = "HTTPS from internet", min = var.https_port, max = var.https_port },
  ] : []

  subnet_ingress = {
    lb = concat(
      [
        { protocol = "6", source = "0.0.0.0/0", description = "HTTP from internet to Service LB", min = var.app_port, max = var.app_port },
        { protocol = "6", source = var.allowed_ssh_cidr, description = "Kubernetes API from laptop", min = var.kubernetes_api_port, max = var.kubernetes_api_port },
        { protocol = "6", source = local.worker_cidr, description = "Kubernetes API from workers", min = var.kubernetes_api_port, max = var.kubernetes_api_port },
        { protocol = "6", source = local.pod_cidr, description = "Kubernetes API from pods", min = var.kubernetes_api_port, max = var.kubernetes_api_port },
        { protocol = "6", source = local.worker_cidr, description = "OKE control from workers", min = var.oke_control_port, max = var.oke_control_port },
      ],
      local.lb_https_ingress,
      local.common_icmp_ingress
    )
    workers = concat(
      [
        { protocol = "all", source = local.worker_cidr, description = "All from worker subnet" },
        { protocol = "all", source = local.pod_cidr, description = "All from pod subnet" },
        { protocol = "6", source = var.allowed_ssh_cidr, description = "SSH from allowed_ssh_cidr", min = 22, max = 22 },
        { protocol = "6", source = local.lb_cidr, description = "Kubelet from API/LB subnet", min = var.kubelet_port, max = var.kubelet_port },
        { protocol = "6", source = local.lb_cidr, description = "Service LB to app port", min = var.app_port, max = var.app_port },
        { protocol = "6", source = local.lb_cidr, description = "Service LB NodePort range", min = var.node_port_min, max = var.node_port_max },
      ],
      local.common_icmp_ingress
    )
    pods = concat(
      [
        { protocol = "all", source = local.worker_cidr, description = "All from worker subnet" },
        { protocol = "all", source = local.pod_cidr, description = "All from pod subnet" },
      ],
      local.common_icmp_ingress
    )
  }

  sgw_route = var.enable_service_gateway ? [
    {
      destination       = module.network.osn_cidr
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = module.network.service_gateway_id
      description       = "All Oracle Services Network via Service Gateway"
    }
  ] : []

  subnets = {
    for k, s in var.subnets : k => {
      display_name               = s.display_name != "" ? s.display_name : "${local.name_prefix}-${k}-subnet"
      cidr                       = s.cidr
      dns_label                  = s.dns_label
      prohibit_public_ip_on_vnic = s.prohibit_public_ip_on_vnic
      route_type                 = s.route_type
      enable_logs                = s.enable_logs
      default_route_gateway_id   = local.gateway_ids[s.route_type]
      default_route_description  = s.route_type == "igw" ? "Default route to Internet Gateway" : "Default route to NAT Gateway"
      extra_route_rules          = s.route_type == "nat" ? local.sgw_route : []
      ingress_security_rules     = lookup(local.subnet_ingress, k, local.common_icmp_ingress)
      egress_security_rules      = local.default_egress
    }
  }
}
