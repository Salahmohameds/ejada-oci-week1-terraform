# VCN, IGW, RTs, SLs, subnets.
# Put 0.0.0.0/0 → IGW on the public *subnet* RT only — not on the IGW itself
# (gateway RTs are a different feature and break the usual public-subnet model).

module "vcn" {
  source = "../../modules/oracle-vcn"

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-vcn"
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = var.vcn_dns_label
  freeform_tags  = local.freeform_tags
}

module "internet_gateway" {
  source = "../../modules/oracle-internet-gateway"

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.name_prefix}-igw"
  enabled        = true
  freeform_tags  = local.freeform_tags
}

module "public_route_table" {
  source = "../../modules/oracle-route-table"

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.name_prefix}-public-rt"
  freeform_tags  = local.freeform_tags

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = module.internet_gateway.id
      description       = "Default route to Internet Gateway (public subnet only)"
    }
  ]
}

# No default route — private subnet stays offline for this lab (no NAT either).
module "private_route_table" {
  source = "../../modules/oracle-route-table"

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.name_prefix}-private-rt"
  freeform_tags  = local.freeform_tags
  route_rules    = []
}

module "public_security_list" {
  source = "../../modules/oracle-security-list"

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.name_prefix}-public-sl"
  freeform_tags  = local.freeform_tags

  ingress_security_rules = [
    {
      protocol    = "6" # TCP
      source      = var.allowed_ssh_cidr
      description = "SSH from allowed_ssh_cidr"
      tcp_options = {
        min = 22
        max = 22
      }
    },
    # Path MTU discovery; common on OCI lab SLs.
    {
      protocol    = "1" # ICMP
      source      = "0.0.0.0/0"
      description = "ICMP type 3 code 4 (path MTU discovery)"
      icmp_options = {
        type = 3
        code = 4
      }
    },
    {
      protocol    = "1"
      source      = var.vcn_cidr
      description = "ICMP within VCN"
      icmp_options = {
        type = 3
      }
    },
  ]

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "Allow all egress"
    }
  ]
}

module "private_security_list" {
  source = "../../modules/oracle-security-list"

  compartment_id = var.compartment_ocid
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.name_prefix}-private-sl"
  freeform_tags  = local.freeform_tags

  ingress_security_rules = [
    {
      protocol    = "all"
      source      = var.vcn_cidr
      description = "Allow traffic from within VCN"
    }
  ]

  egress_security_rules = [
    {
      protocol    = "all"
      destination = var.vcn_cidr
      description = "Egress within VCN only (no internet route on private RT)"
    }
  ]
}

module "public_subnet" {
  source = "../../modules/oracle-subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = module.vcn.vcn_id
  display_name               = "${local.name_prefix}-public-subnet"
  cidr_block                 = var.public_subnet_cidr
  route_table_id             = module.public_route_table.id
  security_list_ids          = [module.public_security_list.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = var.public_subnet_dns_label
  freeform_tags              = local.freeform_tags
}

module "private_subnet" {
  source = "../../modules/oracle-subnet"

  compartment_id             = var.compartment_ocid
  vcn_id                     = module.vcn.vcn_id
  display_name               = "${local.name_prefix}-private-subnet"
  cidr_block                 = var.private_subnet_cidr
  route_table_id             = module.private_route_table.id
  security_list_ids          = [module.private_security_list.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = var.private_subnet_dns_label
  freeform_tags              = local.freeform_tags
}
