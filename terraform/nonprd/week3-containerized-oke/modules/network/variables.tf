variable "compartment_ocid" {
  description = "Compartment OCID for the VCN, gateways, and shared log group."
  type        = string
}

variable "vcn_display_name" {
  description = "VCN display name (e.g. w3-vcn)."
  type        = string
}

variable "vcn_cidr" {
  description = "IPv4 CIDR for the VCN."
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (letters/digits, max 15)."
  type        = string
}

variable "igw_display_name" {
  description = "Internet gateway display name (e.g. w3-igw)."
  type        = string
}

variable "nat_display_name" {
  description = "NAT gateway display name (e.g. w3-nat)."
  type        = string
}

variable "sgw_display_name" {
  description = "Service gateway display name (e.g. w3-sgw)."
  type        = string
}

variable "enable_service_gateway" {
  description = "Create the Service Gateway (All OSN). Private subnet RTs attach the OSN route at the root."
  type        = bool
}

variable "enable_log_group" {
  description = "Create the shared VCN flow-log group. Subnet modules attach per-subnet SERVICE logs to it."
  type        = bool
}

variable "log_group_display_name" {
  description = "Shared flow-log group display name (e.g. w3-vcn-logs)."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags for VCN-core resources."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for VCN-core resources."
  type        = map(string)
  default     = {}
}
