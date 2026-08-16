# VCN core related-group: VCN + IGW + NAT + SGW + shared flow-log group.
# Subnets (RT/SL/logs) stay in modules/subnet. Cluster NSGs stay in modules/oke.

data "oci_core_services" "all_osn" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  osn_service = try(data.oci_core_services.all_osn.services[0], null)
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = var.vcn_dns_label
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# North-south path for the public lb subnet: Kubernetes API + Service LBs.
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.igw_display_name
  enabled        = true
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# Private egress for workers and pods (those VNICs never get a public IP).
resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.nat_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

# Regional Oracle APIs (CSI, Object Storage, Container Engine) without hairpinning NAT.
resource "oci_core_service_gateway" "this" {
  count = var.enable_service_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.sgw_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  services {
    service_id = local.osn_service.id
  }
}

# One shared log group; the subnet module attaches a flow log when enable_logs is true.
resource "oci_logging_log_group" "vcn_flow" {
  count = var.enable_log_group ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = var.log_group_display_name
  description    = "Shared VCN flow logs for ${var.vcn_display_name} subnets"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}
