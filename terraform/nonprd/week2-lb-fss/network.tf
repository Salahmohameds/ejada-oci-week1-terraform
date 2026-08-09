# VCN + IGW + NAT + route tables + security lists + public/private subnets.
# Direct resources (no thin one-resource modules).

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  display_name   = local.vcn_display_name
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = var.vcn_dns_label
  freeform_tags  = local.freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.igw_display_name
  enabled        = true
  freeform_tags  = local.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.nat_display_name
  freeform_tags  = local.freeform_tags
}

# Private path to OCI services (Object Storage, etc.) without hairpinning to Internet.
resource "oci_core_service_gateway" "this" {
  count = var.enable_service_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.sgw_display_name
  freeform_tags  = local.freeform_tags

  services {
    service_id = local.osn_service.id
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = local.public_rt_display_name
  freeform_tags  = local.freeform_tags

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
  display_name   = local.private_rt_display_name
  freeform_tags  = local.freeform_tags

  # General internet (yum/cloud-init) via NAT.
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
    description       = "Default route to NAT Gateway"
  }

  # Prefer SGW for Oracle Services Network when enabled.
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
  display_name   = local.public_sl_display_name
  freeform_tags  = local.freeform_tags

  # Client → ALB HTTP
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

  # Optional HTTPS (listener not created unless you extend later)
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

  # SSH to jump (only meaningful when enable_jump = true)
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
  display_name   = local.private_sl_display_name
  freeform_tags  = local.freeform_tags

  # ALB (public subnet) → app HTTP
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

  # Jump → private app SSH
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

  # NFS — TCP/UDP 111, 2048-2050, 2049 from VCN (VM ↔ mount target)
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
  display_name               = local.public_subnet_display_name
  cidr_block                 = var.public_subnet_cidr
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = var.public_subnet_dns_label
  freeform_tags              = local.freeform_tags
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  display_name               = local.private_subnet_display_name
  cidr_block                 = var.private_subnet_cidr
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = var.private_subnet_dns_label
  freeform_tags              = local.freeform_tags
}
