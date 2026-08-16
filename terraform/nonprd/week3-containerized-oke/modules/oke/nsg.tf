# NSGs stay in the OKE related-group (not a one-resource wrapper).
# Attached on the API endpoint, worker nodes, and (VCN-native) pod VNICs.

locals {
  nsg_api_ids    = var.enable_nsgs ? [oci_core_network_security_group.api[0].id] : []
  nsg_worker_ids = var.enable_nsgs ? [oci_core_network_security_group.workers[0].id] : []
  nsg_pod_ids    = var.enable_nsgs && local.is_native ? [oci_core_network_security_group.pods[0].id] : []

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
}

resource "oci_core_network_security_group" "api" {
  count          = var.enable_nsgs ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = var.nsg_api_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group" "workers" {
  count          = var.enable_nsgs ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = var.nsg_workers_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group" "pods" {
  count          = var.enable_nsgs && local.is_native ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = var.nsg_pods_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_network_security_group_security_rule" "api_ingress_tcp" {
  for_each = var.enable_nsgs ? { for r in local.api_ingress_tcp : r.key => r } : {}

  network_security_group_id = oci_core_network_security_group.api[0].id
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

resource "oci_core_network_security_group_security_rule" "api_egress_all" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.api[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "API egress"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "workers_ingress_tcp" {
  for_each = var.enable_nsgs ? { for r in local.worker_ingress_tcp : r.key => r } : {}

  network_security_group_id = oci_core_network_security_group.workers[0].id
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

resource "oci_core_network_security_group_security_rule" "workers_ingress_from_workers" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.workers[0].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.worker_subnet_cidr
  source_type               = "CIDR_BLOCK"
  description               = "All from worker subnet"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "workers_ingress_from_pods" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.workers[0].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.pod_subnet_cidr
  source_type               = "CIDR_BLOCK"
  description               = "All from pod subnet"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "workers_egress_all" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.workers[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Worker egress (NAT / SGW / API)"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "pods_ingress_from_workers" {
  count = var.enable_nsgs && local.is_native ? 1 : 0

  network_security_group_id = oci_core_network_security_group.pods[0].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.worker_subnet_cidr
  source_type               = "CIDR_BLOCK"
  description               = "All from worker subnet"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "pods_ingress_from_pods" {
  count = var.enable_nsgs && local.is_native ? 1 : 0

  network_security_group_id = oci_core_network_security_group.pods[0].id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.pod_subnet_cidr
  source_type               = "CIDR_BLOCK"
  description               = "All from pod subnet"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "pods_egress_all" {
  count = var.enable_nsgs && local.is_native ? 1 : 0

  network_security_group_id = oci_core_network_security_group.pods[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Pod egress"
  stateless                 = false
}
