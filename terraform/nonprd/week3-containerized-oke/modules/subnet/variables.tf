variable "compartment_ocid" {
  description = "Compartment OCID for the subnet, route table, security list, and optional logs."
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID that owns this subnet, route table, and security list."
  type        = string
}

variable "display_name" {
  description = "Display name for the subnet (RT/SL names derive from this unless overridden)."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR for the subnet."
  type        = string
}

variable "dns_label" {
  description = "DNS label for the subnet (letters/digits, max 15)."
  type        = string
}

variable "prohibit_public_ip_on_vnic" {
  description = "true = private subnet (no public IP on VNICs). false = public."
  type        = bool
}

variable "route_table_display_name" {
  description = "Route table display name. Empty uses display_name-rt."
  type        = string
  default     = ""
}

variable "security_list_display_name" {
  description = "Security list display name. Empty uses display_name-sl."
  type        = string
  default     = ""
}

variable "default_route_gateway_id" {
  description = "IGW or NAT OCID for 0.0.0.0/0. Null skips the default route."
  type        = string
  default     = null
}

variable "default_route_destination" {
  description = "Destination CIDR for the default route rule."
  type        = string
  default     = "0.0.0.0/0"
}

variable "default_route_description" {
  description = "Description on the default route rule."
  type        = string
  default     = "Default route"
}

variable "extra_route_rules" {
  description = "Optional extra RT rules (e.g. Service Gateway). Empty list = none."
  type = list(object({
    destination       = string
    destination_type  = optional(string, "CIDR_BLOCK")
    network_entity_id = string
    description       = optional(string, "")
  }))
  default = []
}

variable "ingress_security_rules" {
  description = "Ingress rules rendered with dynamic blocks. protocol: 1=ICMP, 6=TCP, 17=UDP, all."
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, "")
    stateless   = optional(bool, false)
    min         = optional(number)
    max         = optional(number)
    icmp_type   = optional(number)
    icmp_code   = optional(number)
  }))
  default = []
}

variable "egress_security_rules" {
  description = "Egress rules rendered with dynamic blocks."
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, "")
    stateless        = optional(bool, false)
    min              = optional(number)
    max              = optional(number)
    icmp_type        = optional(number)
    icmp_code        = optional(number)
  }))
  default = []
}

variable "freeform_tags" {
  description = "Freeform tags applied to subnet-related resources."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags applied to subnet-related resources."
  type        = map(string)
  default     = {}
}

# --- Optional VCN flow logs ---

variable "enable_logs" {
  description = "Create a SERVICE flow log (and capture filter) for this subnet."
  type        = bool
  default     = false
}

variable "create_log_group" {
  description = "Create a log group inside this module. Must be a known bool — do not derive it from log_group_id (unknown until apply)."
  type        = bool
  default     = false
}

variable "log_group_id" {
  description = "Log group OCID when create_log_group is false. Required if enable_logs is true and create_log_group is false."
  type        = string
  default     = null
}

variable "log_group_display_name" {
  description = "Log group name when the module creates one. Empty uses display_name-logs."
  type        = string
  default     = ""
}

variable "log_display_name" {
  description = "Flow log display name. Empty uses display_name-flow-log."
  type        = string
  default     = ""
}

variable "log_retention_duration" {
  description = "Log retention in days (30, 60, 90, 120, 150, 180)."
  type        = number
  default     = 30
}

variable "log_category" {
  description = "Logging source category for VCN flow logs."
  type        = string
  default     = "all"
}

variable "log_service" {
  description = "Logging service name for VCN flow logs."
  type        = string
  default     = "flowlogs"
}

variable "create_capture_filter" {
  description = "Create an oci_core_capture_filter and attach it to the flow log."
  type        = bool
  default     = true
}

variable "capture_filter_display_name" {
  description = "Capture filter display name. Empty uses display_name-flow-filter."
  type        = string
  default     = ""
}

variable "flow_log_sampling_rate" {
  description = "Capture-filter sampling rate (1, 10, 50, or 100)."
  type        = number
  default     = 1
}

variable "capture_filter_id" {
  description = "Existing capture filter OCID. Used when create_capture_filter is false."
  type        = string
  default     = null
}
