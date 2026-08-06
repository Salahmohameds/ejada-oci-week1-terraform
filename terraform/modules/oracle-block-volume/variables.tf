variable "compartment_id" {
  description = "OCID of the compartment where the block volume will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the block volume."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the volume (must match instance AD for attachment)."
  type        = string
}

variable "size_in_gbs" {
  description = "Size of the block volume in GBs."
  type        = number
  default     = 50
}

variable "vpus_per_gb" {
  description = "VPU/GB performance tier (10 = Balanced default, 0 = Lower Cost, 20 = Higher Performance)."
  type        = number
  default     = 10
}

variable "attach_to_instance" {
  description = "When true, attach the volume to instance_id."
  type        = bool
  default     = true
}

variable "instance_id" {
  description = "OCID of the instance to attach to. Required when attach_to_instance is true."
  type        = string
  default     = null
}

variable "attachment_type" {
  description = "Volume attachment type: paravirtualized (recommended) or iscsi."
  type        = string
  default     = "paravirtualized"

  validation {
    condition     = contains(["paravirtualized", "iscsi"], var.attachment_type)
    error_message = "attachment_type must be paravirtualized or iscsi."
  }
}

variable "attachment_display_name" {
  description = "Display name for the volume attachment."
  type        = string
  default     = null
}

variable "is_read_only" {
  description = "Whether the attachment is read-only."
  type        = bool
  default     = false
}

variable "is_shareable" {
  description = "Whether the volume can be attached to multiple instances."
  type        = bool
  default     = false
}

variable "device" {
  description = "Optional device path for the attachment (paravirtualized)."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the volume."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the volume."
  type        = map(string)
  default     = {}
}
