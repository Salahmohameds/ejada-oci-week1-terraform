# NSGs stay in the OKE related-group (not a one-resource wrapper).
# Attached on the API endpoint, worker nodes, and (VCN-native) pod VNICs.
# One resource per rule/NSG *shape*, for_each over a map/list — api/workers/pods
# only ever differ by display name, source CIDR, or description, so they are
# never copy-pasted as separate near-identical resource blocks.

locals {
  nsg_display_names = merge(
    {
      api     = var.nsg_api_display_name
      workers = var.nsg_workers_display_name
    },
    local.is_native ? { pods = var.nsg_pods_display_name } : {}
  )

  nsg_api_ids    = var.enable_nsgs ? [oci_core_network_security_group.this["api"].id] : []
  nsg_worker_ids = var.enable_nsgs ? [oci_core_network_security_group.this["workers"].id] : []
  nsg_pod_ids    = var.enable_nsgs && local.is_native ? [oci_core_network_security_group.this["pods"].id] : []

  api_ingress_tcp = [
    { key = "api-from-client", source = var.allowed_api_cidr, min = var.api_port, max = var.api_port, desc = "kubectl to API" },
    { key = "api-from-workers", source = var.worker_subnet_cidr, min = var.api_port, max = var.api_port, desc = "workers to API" },
    { key = "api-from-pods", source = var.pod_subnet_cidr, min = var.api_port, max = var.api_port, desc = "pods to API" },
    { key = "oke-control-from-workers", source = var.worker_subnet_cidr, min = var.oke_control_port, max = var.oke_control_port, desc = "OKE control from workers" },
  ]

  worker_ingress_tcp = [
    { key = "ssh", source = var.allowed_api_cidr, min = 22, max = 22, desc = "SSH to workers" },
    { key = "kubelet", source = var.lb_subnet_cidr, min = var.kubelet_port, max = var.kubelet_port, desc = "API to kubelet" },
    { key = "app-from-lb", source = var.lb_subnet_cidr, min = var.app_port, max = var.app_port, desc = "Service LB to app port" },
    { key = "nodeport-from-lb", source = var.lb_subnet_cidr, min = var.node_port_min, max = var.node_port_max, desc = "Service LB NodePort range" },
  ]

  # workers/pods "allow all" ingress from each other's subnet — same rule shape
  # on both NSGs with the source flipped, driven from one map instead of four
  # copy-pasted single-count resources.
  nsg_all_ingress = merge(
    {
      "workers-from-workers" = { nsg = "workers", source = var.worker_subnet_cidr, desc = "All from worker subnet" }
      "workers-from-pods"    = { nsg = "workers", source = var.pod_subnet_cidr, desc = "All from pod subnet" }
    },
    local.is_native ? {
      "pods-from-workers" = { nsg = "pods", source = var.worker_subnet_cidr, desc = "All from worker subnet" }
      "pods-from-pods"    = { nsg = "pods", source = var.pod_subnet_cidr, desc = "All from pod subnet" }
    } : {}
  )

  # Same "allow all egress to 0.0.0.0/0" rule on every NSG — only the
  # description changes, so one map drives one resource instead of three.
  nsg_egress_all = merge(
    {
      api     = "API egress"
      workers = "Worker egress (NAT / SGW / API)"
    },
    local.is_native ? { pods = "Pod egress" } : {}
  )
}

resource "oci_core_network_security_group" "this" {
  for_each = var.enable_nsgs ? local.nsg_display_names : {}

  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = each.value
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "api_ingress_tcp" {
  for_each = var.enable_nsgs ? { for r in local.api_ingress_tcp : r.key => r } : {}

  network_security_group_id = oci_core_network_security_group.this["api"].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value.source
  source_type               = "CIDR_BLOCK"
  description               = each.value.desc
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = each.value.min
      max = each.value.max
    }
  }
}

resource "oci_core_network_security_group_security_rule" "workers_ingress_tcp" {
  for_each = var.enable_nsgs ? { for r in local.worker_ingress_tcp : r.key => r } : {}

  network_security_group_id = oci_core_network_security_group.this["workers"].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value.source
  source_type               = "CIDR_BLOCK"
  description               = each.value.desc
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = each.value.min
      max = each.value.max
    }
  }
}

resource "oci_core_network_security_group_security_rule" "all_ingress" {
  for_each = var.enable_nsgs ? local.nsg_all_ingress : {}

  network_security_group_id = oci_core_network_security_group.this[each.value.nsg].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = each.value.source
  source_type               = "CIDR_BLOCK"
  description               = each.value.desc
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "egress_all" {
  for_each = var.enable_nsgs ? local.nsg_egress_all : {}

  network_security_group_id = oci_core_network_security_group.this[each.key].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = each.value
  stateless                 = false
}
