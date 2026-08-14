variable "compartment_ocid" {
  description = "Compartment OCID for compute resources."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for instances."
  type        = string
}

variable "image_id" {
  description = "OCID of the boot image."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet for the app instance."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet for the optional jump host."
  type        = string
}

variable "nsg_app_ids" {
  description = "NSG OCIDs attached to the app VNIC."
  type        = list(string)
  default     = []
}

variable "freeform_tags" {
  description = "Freeform tags for instances."
  type        = map(string)
  default     = {}
}

variable "ssh_public_key" {
  description = "SSH public key for instance metadata."
  type        = string
  sensitive   = true
}

variable "instance_shape" {
  description = "Compute shape for app (and jump if enabled)."
  type        = string
}

variable "instance_ocpus" {
  description = "OCPUs for the app instance."
  type        = number
}

variable "instance_memory_in_gbs" {
  description = "Memory (GB) for the app instance."
  type        = number
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size (GB)."
  type        = number
}

variable "app_instance_display_name" {
  description = "Private app instance display name."
  type        = string
}

variable "app_hostname_label" {
  description = "Hostname label for the app VNIC."
  type        = string
}

variable "app_port" {
  description = "HTTP port served by the private app."
  type        = number
}

variable "app_mount_path" {
  description = "Local directory where FSS is mounted."
  type        = string
}

variable "app_index_html_body" {
  description = "HTML body written to the FSS mount as index.html."
  type        = string
}

variable "enable_fss" {
  description = "Whether cloud-init should mount FSS."
  type        = bool
}

variable "fss_export_path" {
  description = "NFS export path for cloud-init."
  type        = string
}

variable "mount_target_ip" {
  description = "Mount target private IP for cloud-init (empty when FSS disabled)."
  type        = string
  default     = ""
}

variable "enable_jump" {
  description = "Create a public jump host."
  type        = bool
}

variable "jump_instance_display_name" {
  description = "Jump host display name."
  type        = string
}

variable "jump_hostname_label" {
  description = "Hostname label for the jump VNIC."
  type        = string
}

variable "jump_ocpus" {
  description = "OCPUs for the jump host."
  type        = number
}

variable "jump_memory_in_gbs" {
  description = "Memory (GB) for the jump host."
  type        = number
}
