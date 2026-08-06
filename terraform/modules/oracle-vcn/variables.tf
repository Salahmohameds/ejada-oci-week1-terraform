variable "compartment_id" {
  description = "OCID of the compartment where the VCN will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the VCN."
  type        = string
}

variable "cidr_blocks" {
  description = "List of IPv4 CIDR blocks for the VCN."
  type        = list(string)

  validation {
    condition     = length(var.cidr_blocks) > 0
    error_message = "At least one CIDR block is required."
  }
}

variable "dns_label" {
  description = "DNS label for the VCN (letters/digits only, max 15 chars). Empty string skips DNS."
  type        = string
  default     = ""
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the VCN."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the VCN."
  type        = map(string)
  default     = {}
}
