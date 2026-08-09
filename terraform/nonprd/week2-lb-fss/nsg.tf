# NSGs (primary intent per PDF). Security lists stay on subnets as defense-in-depth.

# --- LB NSG: internet → HTTP(S); egress to private app port ---
resource "oci_core_network_security_group" "lb" {
  count = var.enable_nsgs ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.nsg_lb_display_name
  freeform_tags  = local.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_http" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.lb[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP from internet to ALB"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.app_port
      max = var.app_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_https" {
  count = var.enable_nsgs && var.enable_https_ingress ? 1 : 0

  network_security_group_id = oci_core_network_security_group.lb[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTPS from internet (listener not created by default)"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_egress_app" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.lb[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.private_subnet_cidr
  destination_type          = "CIDR_BLOCK"
  description               = "LB backends to app port in private subnet"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.app_port
      max = var.app_port
    }
  }
}

# --- App NSG: LB → HTTP; bastion/jump → SSH; private → NFS; egress open for NAT ---
resource "oci_core_network_security_group" "app" {
  count = var.enable_nsgs ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.nsg_app_display_name
  freeform_tags  = local.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "app_ingress_http_from_lb_nsg" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.app[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.lb[0].id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "HTTP from LB NSG"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.app_port
      max = var.app_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_ingress_http_from_public_cidr" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.app[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.public_subnet_cidr
  source_type               = "CIDR_BLOCK"
  description               = "HTTP from public subnet (ALB VNICs)"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.app_port
      max = var.app_port
    }
  }
}

# Bastion PE lives in target (private) subnet; jump (if any) in public.
resource "oci_core_network_security_group_security_rule" "app_ingress_ssh_from_vcn" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.app[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  description               = "SSH from VCN (Bastion PE / jump path)"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_egress_all" {
  count = var.enable_nsgs ? 1 : 0

  network_security_group_id = oci_core_network_security_group.app[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Egress for NAT, OSN via SGW, and NFS"
  stateless                 = false
}

# --- Mount target NSG: NFS from VCN (app) ---
resource "oci_core_network_security_group" "mt" {
  count = var.enable_nsgs && var.enable_fss ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.nsg_mt_display_name
  freeform_tags  = local.freeform_tags
}

locals {
  # NFS port ranges used on MT NSG (mirrors private SL rules).
  nsg_mt_nfs_rules = var.enable_nsgs && var.enable_fss ? [
    { proto = "6", min = 111, max = 111, desc = "NFS portmapper TCP" },
    { proto = "6", min = 2048, max = 2050, desc = "NFS mountd/statd TCP" },
    { proto = "6", min = 2049, max = 2049, desc = "NFS TCP" },
    { proto = "17", min = 111, max = 111, desc = "NFS portmapper UDP" },
    { proto = "17", min = 2048, max = 2050, desc = "NFS mountd/statd UDP" },
    { proto = "17", min = 2049, max = 2049, desc = "NFS UDP" },
  ] : []
}

resource "oci_core_network_security_group_security_rule" "mt_ingress_nfs" {
  for_each = { for r in local.nsg_mt_nfs_rules : "${r.proto}-${r.min}-${r.max}" => r }

  network_security_group_id = oci_core_network_security_group.mt[0].id
  direction                 = "INGRESS"
  protocol                  = each.value.proto
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  description               = each.value.desc
  stateless                 = false

  dynamic "tcp_options" {
    for_each = each.value.proto == "6" ? [1] : []
    content {
      destination_port_range {
        min = each.value.min
        max = each.value.max
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.proto == "17" ? [1] : []
    content {
      destination_port_range {
        min = each.value.min
        max = each.value.max
      }
    }
  }
}

resource "oci_core_network_security_group_security_rule" "mt_egress_all" {
  count = var.enable_nsgs && var.enable_fss ? 1 : 0

  network_security_group_id = oci_core_network_security_group.mt[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "MT egress (NFS responses)"
  stateless                 = false
}
