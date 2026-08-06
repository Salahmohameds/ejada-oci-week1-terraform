variable "compartment_id" {
  description = "OCID of the compartment for File Storage resources."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the file system and mount target."
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the mount target (typically public or private app subnet)."
  type        = string
}

variable "file_system_display_name" {
  description = "Display name for the file system."
  type        = string
}

variable "mount_target_display_name" {
  description = "Display name for the mount target."
  type        = string
}

variable "export_path" {
  description = "NFS export path (must start with /)."
  type        = string
  default     = "/export"

  validation {
    condition     = startswith(var.export_path, "/")
    error_message = "export_path must start with '/'."
  }
}

variable "export_source_cidr" {
  description = "CIDR allowed to mount the export (source for export options)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "export_access" {
  description = "Export access level (READ_WRITE or READ_ONLY)."
  type        = string
  default     = "READ_WRITE"
}

variable "nsg_ids" {
  description = "Optional NSG OCIDs for the mount target."
  type        = list(string)
  default     = []
}

variable "hostname_label" {
  description = "Optional hostname label for the mount target."
  type        = string
  default     = null
}

variable "freeform_tags" {
  description = "Freeform tags for FSS resources."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for FSS resources."
  type        = map(string)
  default     = {}
}
