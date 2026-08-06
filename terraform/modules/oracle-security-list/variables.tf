variable "compartment_id" {
  description = "OCID of the compartment where the security list will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN that owns this security list."
  type        = string
}

variable "display_name" {
  description = "Display name for the security list."
  type        = string
}

variable "ingress_security_rules" {
  description = "Ingress security rules."
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string)
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }))
    udp_options = optional(object({
      min = number
      max = number
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number)
    }))
  }))
  default = []
}

variable "egress_security_rules" {
  description = "Egress security rules."
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string)
    stateless        = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }))
    udp_options = optional(object({
      min = number
      max = number
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number)
    }))
  }))
  default = []
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the security list."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the security list."
  type        = map(string)
  default     = {}
}
