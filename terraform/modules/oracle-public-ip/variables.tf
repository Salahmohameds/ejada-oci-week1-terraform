variable "compartment_id" {
  description = "OCID of the compartment where the public IP will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the public IP resource."
  type        = string
}

variable "lifetime" {
  description = "Public IP lifetime: RESERVED (static, survives unassign) or EPHEMERAL."
  type        = string
  default     = "RESERVED"

  validation {
    condition     = contains(["RESERVED", "EPHEMERAL"], var.lifetime)
    error_message = "lifetime must be RESERVED or EPHEMERAL."
  }
}

variable "private_ip_id" {
  description = "OCID of the private IP to assign this public IP to. Provide this or vnic_id."
  type        = string
  default     = null
}

variable "vnic_id" {
  description = "VNIC OCID used to look up the primary private IP when private_ip_id is null."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the public IP."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the public IP."
  type        = map(string)
  default     = {}
}
