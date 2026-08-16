# Subnet related-group: subnet + route table + security list + optional flow logs.
# Generic: ingress/egress/route rules are dynamic blocks; logs use count.

locals {
  route_table_display_name    = var.route_table_display_name != "" ? var.route_table_display_name : "${var.display_name}-rt"
  security_list_display_name  = var.security_list_display_name != "" ? var.security_list_display_name : "${var.display_name}-sl"
  log_group_display_name      = var.log_group_display_name != "" ? var.log_group_display_name : "${var.display_name}-logs"
  log_display_name            = var.log_display_name != "" ? var.log_display_name : "${var.display_name}-flow-log"
  capture_filter_display_name = var.capture_filter_display_name != "" ? var.capture_filter_display_name : "${var.display_name}-flow-filter"

  # create_log_group must be a known bool (never derived from log_group_id — that OCID is unknown until apply).
  create_log_group = var.enable_logs && var.create_log_group
  log_group_id     = var.enable_logs ? (var.create_log_group ? try(oci_logging_log_group.this[0].id, null) : var.log_group_id) : null

  capture_filter_id = var.enable_logs && var.create_capture_filter ? try(oci_core_capture_filter.flow[0].id, null) : var.capture_filter_id
}

resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = local.security_list_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  dynamic "ingress_security_rules" {
    for_each = var.ingress_security_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" && ingress_security_rules.value.min != null ? [1] : []
        content {
          min = ingress_security_rules.value.min
          max = ingress_security_rules.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" && ingress_security_rules.value.min != null ? [1] : []
        content {
          min = ingress_security_rules.value.min
          max = ingress_security_rules.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.protocol == "1" && ingress_security_rules.value.icmp_type != null ? [1] : []
        content {
          type = ingress_security_rules.value.icmp_type
          code = ingress_security_rules.value.icmp_code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.egress_security_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "6" && egress_security_rules.value.min != null ? [1] : []
        content {
          min = egress_security_rules.value.min
          max = egress_security_rules.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "17" && egress_security_rules.value.min != null ? [1] : []
        content {
          min = egress_security_rules.value.min
          max = egress_security_rules.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.protocol == "1" && egress_security_rules.value.icmp_type != null ? [1] : []
        content {
          type = egress_security_rules.value.icmp_type
          code = egress_security_rules.value.icmp_code
        }
      }
    }
  }
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = local.route_table_display_name
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  dynamic "route_rules" {
    for_each = var.default_route_gateway_id != null ? [1] : []
    content {
      destination       = var.default_route_destination
      destination_type  = "CIDR_BLOCK"
      network_entity_id = var.default_route_gateway_id
      description       = var.default_route_description
    }
  }

  dynamic "route_rules" {
    for_each = var.extra_route_rules
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_subnet" "this" {
  # Own RT + SL attached here so the module is a complete related group.
  compartment_id             = var.compartment_ocid
  vcn_id                     = var.vcn_id
  display_name               = var.display_name
  cidr_block                 = var.cidr_block
  dns_label                  = var.dns_label
  route_table_id             = oci_core_route_table.this.id
  security_list_ids          = [oci_core_security_list.this.id]
  prohibit_public_ip_on_vnic = var.prohibit_public_ip_on_vnic
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags
}

resource "oci_logging_log_group" "this" {
  count = local.create_log_group ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = local.log_group_display_name
  description    = "VCN flow logs for ${var.display_name}"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_capture_filter" "flow" {
  count = var.enable_logs && var.create_capture_filter ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = local.capture_filter_display_name
  filter_type    = "FLOWLOG"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  flow_log_capture_filter_rules {
    is_enabled    = true
    priority      = 1
    sampling_rate = var.flow_log_sampling_rate
    flow_log_type = "ALL"
  }
}

resource "oci_logging_log" "flow" {
  count = var.enable_logs ? 1 : 0

  display_name       = local.log_display_name
  log_group_id       = local.log_group_id
  log_type           = "SERVICE"
  is_enabled         = true
  retention_duration = var.log_retention_duration
  freeform_tags      = var.freeform_tags
  defined_tags       = var.defined_tags

  configuration {
    compartment_id = var.compartment_ocid

    source {
      category    = var.log_category
      resource    = oci_core_subnet.this.id
      service     = var.log_service
      source_type = "OCISERVICE"
      parameters  = local.capture_filter_id != null ? { capture_filter = local.capture_filter_id } : {}
    }
  }
}
