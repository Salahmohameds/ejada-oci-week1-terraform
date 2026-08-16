# OKE related-group: cluster + OCI_VCN_IP_NATIVE + managed node pool.
# Optional API / worker / pod NSGs are in nsg.tf (same module — not a split wrapper).
#
# VCN-native CNI: each pod gets a VCN IP from the pod subnet instead of a Flannel
# overlay. Required by this lab. Overlay pods_cidr is ignored when is_native.

locals {
  is_native     = var.cni_type == "OCI_VCN_IP_NATIVE"
  is_flex_shape = strcontains(upper(var.node_shape), "FLEX")
}

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  type               = var.cluster_type
  freeform_tags      = var.freeform_tags
  defined_tags       = var.defined_tags

  cluster_pod_network_options {
    cni_type = var.cni_type
  }

  endpoint_config {
    is_public_ip_enabled = var.endpoint_public
    subnet_id            = var.endpoint_subnet_id
    nsg_ids              = local.nsg_api_ids
  }

  options {
    service_lb_subnet_ids = [var.service_lb_subnet_id]

    add_ons {
      is_kubernetes_dashboard_enabled = var.dashboard_enabled
      is_tiller_enabled               = false
    }

    kubernetes_network_config {
      services_cidr = var.services_cidr
      # Overlay CIDR is Flannel-only; VCN-native pods take IPs from the pod subnet.
      pods_cidr = local.is_native ? null : var.pods_cidr
    }
  }

  lifecycle {
    precondition {
      condition     = var.kubernetes_version != ""
      error_message = "kubernetes_version is empty. Set it in tfvars or ensure cluster_option returned versions."
    }
    precondition {
      condition     = !local.is_native || length(var.pod_subnet_ids) > 0
      error_message = "OCI_VCN_IP_NATIVE requires pod_subnet_ids (a dedicated pod subnet)."
    }
  }
}

resource "oci_containerengine_node_pool" "this" {
  cluster_id         = oci_containerengine_cluster.this.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.node_pool_name
  node_shape         = var.node_shape
  ssh_public_key     = var.ssh_public_key
  freeform_tags      = var.freeform_tags
  defined_tags       = var.defined_tags

  node_config_details {
    size                                = var.node_pool_size
    nsg_ids                             = local.nsg_worker_ids
    is_pv_encryption_in_transit_enabled = false

    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.worker_subnet_id
    }

    node_pool_pod_network_option_details {
      cni_type          = var.cni_type
      max_pods_per_node = local.is_native ? var.max_pods_per_node : null
      pod_subnet_ids    = local.is_native ? var.pod_subnet_ids : null
      pod_nsg_ids       = local.is_native && length(local.nsg_pod_ids) > 0 ? local.nsg_pod_ids : null
    }
  }

  dynamic "node_shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      ocpus         = var.node_ocpus
      memory_in_gbs = var.node_memory_in_gbs
    }
  }

  node_source_details {
    image_id                = var.node_image_id
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = var.node_boot_volume_size_in_gbs
  }

  lifecycle {
    precondition {
      condition     = var.node_image_id != ""
      error_message = "node_image_id is empty. Set oke_node_image_id in terraform.tfvars, or check the node_pool_option lookup."
    }
    precondition {
      condition     = var.worker_subnet_id != null && var.worker_subnet_id != ""
      error_message = "worker_subnet_id is required for the managed node pool."
    }
    precondition {
      condition     = length(var.ssh_public_key) > 20
      error_message = "ssh_public_key must be set in terraform.tfvars before creating the node pool."
    }
  }
}
