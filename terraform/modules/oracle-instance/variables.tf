variable "compartment_id" {
  description = "OCID of the compartment where the instance will be created."
  type        = string
}

variable "display_name" {
  description = "Display name for the compute instance."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the instance."
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet for the primary VNIC."
  type        = string
}

variable "shape" {
  description = "Compute shape (e.g. VM.Standard.E4.Flex, VM.Standard.A1.Flex)."
  type        = string
}

variable "ssh_public_keys" {
  description = "SSH public key(s) injected via cloud-init metadata."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the primary VNIC."
  type        = bool
  default     = true
}

variable "hostname_label" {
  description = "Hostname label for the VNIC (requires DNS on VCN/subnet)."
  type        = string
  default     = null
}

variable "shape_config" {
  description = "OCPU/memory for flexible shapes. Null for fixed-shape instances."
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = null
}

variable "source_type" {
  description = "Boot volume source type (image or bootVolume)."
  type        = string
  default     = "image"
}

variable "image_operating_system" {
  description = "Operating system filter for image data source."
  type        = string
  default     = "Oracle Linux"
}

variable "image_operating_system_version" {
  description = "Operating system version filter for image data source."
  type        = string
  default     = "9"
}

variable "image_shape" {
  description = "Shape to filter compatible images. Defaults to var.shape."
  type        = string
  default     = null
}

variable "boot_volume_size_in_gbs" {
  description = "Optional boot volume size override in GB."
  type        = number
  default     = null
}

variable "user_data" {
  description = "Optional cloud-init user_data (base64-encoded or plain; provider accepts raw)."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the instance."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the instance."
  type        = map(string)
  default     = {}
}
