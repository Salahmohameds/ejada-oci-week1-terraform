variable "compartment_ocid" {
  description = "Compartment OCID for compute resources."
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for instances."
  type        = string
}

variable "image_id" {
  description = "OCID of the boot image (shared by all instances)."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags for instances."
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = <<-EOT
    Map of compute instances to create, keyed by a short logical name (e.g. "app", "jump").
    One oci_core_instance is created per map entry via for_each — add/remove entries to
    add/remove VMs instead of adding new module calls or resource blocks.
  EOT
  type = map(object({
    display_name            = string
    shape                   = string
    ocpus                   = number
    memory_in_gbs           = number
    boot_volume_size_in_gbs = number
    subnet_id               = string
    assign_public_ip        = bool
    hostname_label          = string
    nsg_ids                 = optional(list(string), [])
    ssh_public_key          = string
    # Optional cloud-init inputs. Leave null (default) for instances that don't need
    # the FSS-mount + HTTP bootstrap script (e.g. a plain jump host).
    cloud_init = optional(object({
      mount_target_ip  = string
      fss_export_path  = string
      app_mount_path   = string
      app_port         = number
      index_html_body  = string
      enable_fss_mount = bool
    }))
  }))
}
