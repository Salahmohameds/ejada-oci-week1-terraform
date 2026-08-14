variable "compartment_ocid" {
  description = "Compartment OCID for File Storage resources."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for FS and mount target."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet OCID for the mount target."
  type        = string
}

variable "nsg_ids" {
  description = "NSG OCIDs attached to the mount target."
  type        = list(string)
  default     = []
}

variable "freeform_tags" {
  description = "Freeform tags for FSS resources."
  type        = map(string)
  default     = {}
}

variable "enable_fss" {
  description = "Create file system + mount target + export."
  type        = bool
}

variable "fss_display_name" {
  description = "File system display name."
  type        = string
}

variable "mount_target_display_name" {
  description = "Mount target display name."
  type        = string
}

variable "mount_target_hostname_label" {
  description = "Hostname label for the mount target."
  type        = string
}

variable "fss_export_path" {
  description = "NFS export path on the file system."
  type        = string
}

variable "fss_export_source_cidr" {
  description = "Client CIDR allowed on the FSS export."
  type        = string
}

variable "fss_export_access" {
  description = "Export access level (READ_WRITE or READ_ONLY)."
  type        = string
}
