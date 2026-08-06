variable "compartment_id" {
  description = "OCID of the compartment where the subnet will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN that owns this subnet."
  type        = string
}

variable "display_name" {
  description = "Display name for the subnet."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the subnet (must be within the VCN CIDR)."
  type        = string
}

variable "route_table_id" {
  description = "OCID of the route table to associate with the subnet."
  type        = string
}

variable "security_list_ids" {
  description = "List of security list OCIDs to associate with the subnet."
  type        = list(string)
}

variable "prohibit_public_ip_on_vnic" {
  description = "When true, prevents public IPs on VNICs (private subnet). When false, public IPs are allowed."
  type        = bool
  default     = false
}

variable "dns_label" {
  description = "DNS label for the subnet. Empty string skips DNS label."
  type        = string
  default     = ""
}

variable "availability_domain" {
  description = "Availability domain for a regional or AD-specific subnet. Leave empty for regional subnet."
  type        = string
  default     = null
}

variable "dhcp_options_id" {
  description = "Optional DHCP options OCID. Null uses VCN default."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the subnet."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the subnet."
  type        = map(string)
  default     = {}
}
