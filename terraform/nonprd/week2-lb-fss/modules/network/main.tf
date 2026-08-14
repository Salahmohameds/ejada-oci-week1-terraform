# Cohesive network edge: VCN + gateways + RTs + SLs + NSGs + subnets.

data "oci_core_services" "all_osn" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  osn_service = try(data.oci_core_services.all_osn.services[0], null)

  nsg_mt_nfs_rules = var.enable_nsgs && var.enable_fss ? [
    { proto = "6", min = 111, max = 111, desc = "NFS portmapper TCP" },
    { proto = "6", min = 2048, max = 2050, desc = "NFS mountd/statd TCP" },
    { proto = "6", min = 2049, max = 2049, desc = "NFS TCP" },
    { proto = "17", min = 111, max = 111, desc = "NFS portmapper UDP" },
    { proto = "17", min = 2048, max = 2050, desc = "NFS mountd/statd UDP" },
    { proto = "17", min = 2049, max = 2049, desc = "NFS UDP" },
  ] : []
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = var.vcn_dns_label
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.igw_display_name
  enabled        = true
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.nat_display_name
  freeform_tags  = var.freeform_tags
}

# Private path to OCI services (Object Storage, etc.) without hairpinning to Internet.
resource "oci_core_service_gateway" "this" {
  count = var.enable_service_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.sgw_display_name
  freeform_tags  = var.freeform_tags

  services {
    service_id = local.osn_service.id
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.public_rt_display_name
  freeform_tags  = var.freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
    description       = "Default route to Internet Gateway"
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.private_rt_display_name
  freeform_tags  = var.freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
    description       = "Default route to NAT Gateway"
  }

  dynamic "route_rules" {
    for_each = var.enable_service_gateway ? [1] : []
    content {
      destination       = local.osn_service.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this[0].id
      description       = "All Oracle Services Network via Service Gateway"
    }
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.public_sl_display_name
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "HTTP from internet to ALB"
    stateless   = false

    tcp_options {
      min = var.app_port
      max = var.app_port
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.enable_https_ingress ? [1] : []
    content {
      protocol    = "6"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "HTTPS from internet"
      stateless   = false

      tcp_options {
        min = 443
        max = 443
      }
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.allowed_ssh_cidr
    source_type = "CIDR_BLOCK"
    description = "SSH from allowed_ssh_cidr"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "ICMP type 3 code 4 (path MTU discovery)"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol    = "1"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "ICMP type 3 within VCN"
    stateless   = false

    icmp_options {
      type = 3
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all egress"
    stateless        = false
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.private_sl_display_name
  freeform_tags  = var.freeform_tags

  ingress_security_rules {
    protocol    = "6"
    source      = var.public_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "HTTP from public subnet (ALB backends)"
    stateless   = false

    tcp_options {
      min = var.app_port
      max = var.app_port
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.public_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "SSH from public subnet (jump)"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  dynamic "ingress_security_rules" {
    for_each = [
      { proto = "6", min = 111, max = 111, desc = "NFS portmapper TCP" },
      { proto = "6", min = 2048, max = 2050, desc = "NFS mountd/statd TCP" },
      { proto = "6", min = 2049, max = 2049, desc = "NFS TCP" },
      { proto = "17", min = 111, max = 111, desc = "NFS portmapper UDP" },
      { proto = "17", min = 2048, max = 2050, desc = "NFS mountd/statd UDP" },
      { proto = "17", min = 2049, max = 2049, desc = "NFS UDP" },
    ]
    content {
      protocol    = ingress_security_rules.value.proto
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      description = ingress_security_rules.value.desc
      stateless   = false

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.proto == "6" ? [1] : []
        content {
          min = ingress_security_rules.value.min
          max = ingress_security_rules.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.proto == "17" ? [1] : []
        content {
          min = ingress_security_rules.value.min
          max = ingress_security_rules.value.max
        }
      }
    }
  }

  ingress_security_rules {
    protocol    = "1"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "ICMP within VCN"
    stateless   = false

    icmp_options {
      type = 3
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all egress (NAT + NFS)"
    stateless        = false
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = var.public_subnet_display_name
  cidr_block                 = var.public_subnet_cidr
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = var.public_subnet_dns_label
  freeform_tags              = var.freeform_tags
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = var.private_subnet_display_name
  cidr_block                 = var.private_subnet_cidr
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = var.private_subnet_dns_label
  freeform_tags              = var.freeform_tags
}

# --- LB NSG ---
resource "oci_core_network_security_group" "lb" {
  count = var.enable_nsgs ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.nsg_lb_display_name
  freeform_tags  = var.freeform_tags
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

# --- App NSG ---
resource "oci_core_network_security_group" "app" {
  count = var.enable_nsgs ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.nsg_app_display_name
  freeform_tags  = var.freeform_tags
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

# --- Mount target NSG ---
resource "oci_core_network_security_group" "mt" {
  count = var.enable_nsgs && var.enable_fss ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.nsg_mt_display_name
  freeform_tags  = var.freeform_tags
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
