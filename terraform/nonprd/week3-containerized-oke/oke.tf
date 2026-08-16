# OKE related group: cluster + VCN-native pod networking + managed node pool.
# count = enable_oke so Stage A can apply network-only. Workloads stay in k8s/
# (kubectl after the cluster is ACTIVE — no Kubernetes provider here).

# Node-pool placement (identity data, not part of modules/network).
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Region catalog. Passing intern-18 as compartment_id returns empty versions / 404.
data "oci_containerengine_cluster_option" "all" {
  count = var.enable_oke ? 1 : 0

  cluster_option_id = "all"
}

# May return empty sources when intern-18 lacks node-pool-options; pin oke_node_image_id in tfvars.
data "oci_containerengine_node_pool_option" "all" {
  count = var.enable_oke ? 1 : 0

  node_pool_option_id = "all"
  compartment_id      = var.compartment_ocid
}

module "oke" {
  count  = var.enable_oke ? 1 : 0
  source = "./modules/oke"

  compartment_ocid             = var.compartment_ocid
  vcn_id                       = module.network.vcn_id
  cluster_name                 = local.oke_cluster_display_name
  cluster_type                 = var.oke_cluster_type
  kubernetes_version           = local.kubernetes_version
  cni_type                     = var.oke_cni_type
  endpoint_public              = var.oke_endpoint_public
  endpoint_subnet_id           = module.subnet["lb"].subnet_id
  worker_subnet_id             = module.subnet["workers"].subnet_id
  pod_subnet_ids               = [module.subnet["pods"].subnet_id]
  service_lb_subnet_id         = module.subnet["lb"].subnet_id
  services_cidr                = var.oke_services_cidr
  pods_cidr                    = var.oke_pods_cidr
  dashboard_enabled            = var.oke_dashboard_enabled
  availability_domain          = local.availability_domain
  node_pool_name               = local.oke_node_pool_display_name
  node_pool_size               = var.oke_node_pool_size
  node_shape                   = var.oke_node_shape
  node_ocpus                   = var.oke_node_ocpus
  node_memory_in_gbs           = var.oke_node_memory_in_gbs
  node_boot_volume_size_in_gbs = var.oke_node_boot_volume_size_in_gbs
  node_image_id                = local.oke_node_image_id
  ssh_public_key               = var.ssh_public_key
  max_pods_per_node            = var.oke_max_pods_per_node
  freeform_tags                = local.freeform_tags
  defined_tags                 = local.defined_tags

  enable_nsgs              = var.enable_oke_nsgs
  nsg_api_display_name     = local.nsg_oke_api_display_name
  nsg_workers_display_name = local.nsg_oke_workers_display_name
  nsg_pods_display_name    = local.nsg_oke_pods_display_name
  worker_subnet_cidr       = local.worker_cidr
  pod_subnet_cidr          = local.pod_cidr
  lb_subnet_cidr           = local.lb_cidr
  allowed_api_cidr         = var.allowed_ssh_cidr
  api_port                 = var.kubernetes_api_port
  oke_control_port         = var.oke_control_port
  kubelet_port             = var.kubelet_port
  app_port                 = var.app_port
  node_port_min            = var.node_port_min
  node_port_max            = var.node_port_max

  depends_on = [module.subnet]
}
