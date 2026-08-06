variable "compartment_id" {
  description = "OCID of the compartment where the internet gateway will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN to attach the internet gateway to."
  type        = string
}

variable "display_name" {
  description = "Display name for the internet gateway."
  type        = string
}

variable "enabled" {
  description = "Whether the internet gateway is enabled."
  type        = bool
  default     = true
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the internet gateway."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the internet gateway."
  type        = map(string)
  default     = {}
}
