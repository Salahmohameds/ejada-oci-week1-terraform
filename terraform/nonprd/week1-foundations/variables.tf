# ---------------------------------------------------------------------------
# Authentication / tenancy
# ---------------------------------------------------------------------------

variable "region" {
  description = "OCI region home for this stack."
  type        = string
  default     = "me-jeddah-1"
}

variable "config_file_profile" {
  description = "Profile name from ~/.oci/config used by the OCI provider."
  type        = string
  default     = "DEFAULT"
}

variable "tenancy_ocid" {
  description = "Tenancy OCID. Optional when using config_file_profile exclusively; set only for explicit API-key auth."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_ocid" {
  description = "User OCID for explicit API-key auth. Leave null when using config_file_profile."
  type        = string
  default     = null
  sensitive   = true
}

variable "fingerprint" {
  description = "API key fingerprint for explicit API-key auth. Leave null when using config_file_profile."
  type        = string
  default     = null
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the PEM private key for explicit API-key auth. Never commit the key. Leave null when using config_file_profile."
  type        = string
  default     = null
  sensitive   = true
}

variable "compartment_ocid" {
  description = "Compartment OCID where Week 1 Lab 1 resources are created."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming / tags
# ---------------------------------------------------------------------------

variable "name_prefix" {
  description = "Short prefix for resource display names (e.g. w1)."
  type        = string
  default     = "w1"
}

variable "project_tag" {
  description = "Freeform Project tag value."
  type        = string
  default     = "Ejada-Cloud-Build"
}

variable "lab_tag" {
  description = "Freeform Lab tag value."
  type        = string
  default     = "week1-lab1"
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (TCP/22) into the public subnet. Prefer YOUR_PUBLIC_IP/32 for labs that are not open to the world."
  type        = string
  # No default on purpose — force an explicit choice in terraform.tfvars.
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (letters/digits, max 15)."
  type        = string
  default     = "w1vcn"
}

variable "public_subnet_dns_label" {
  description = "DNS label for the public subnet."
  type        = string
  default     = "public"
}

variable "private_subnet_dns_label" {
  description = "DNS label for the private subnet."
  type        = string
  default     = "private"
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "SSH public key content placed on the instance (ssh-ed25519 / ssh-rsa line)."
  type        = string
  sensitive   = true
}

variable "instance_display_name" {
  description = "Display name override for the compute instance. Empty uses name_prefix-linux-vm."
  type        = string
  default     = ""
}

variable "instance_shape" {
  description = "Compute shape for the lab VM."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "OCPUs for flexible shapes."
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memory (GB) for flexible shapes."
  type        = number
  default     = 8
}

variable "instance_assign_public_ip" {
  description = "When use_reserved_public_ip is false, assign an ephemeral public IP on the primary VNIC."
  type        = bool
  default     = true
}

variable "use_reserved_public_ip" {
  description = "When true, create a RESERVED public IP and attach it to the instance primary private IP (assign_public_ip forced false). When false, use ephemeral public IP via instance_assign_public_ip."
  type        = bool
  default     = true
}

variable "availability_domain_index" {
  description = "Zero-based index into data.oci_identity_availability_domains for the region."
  type        = number
  default     = 0
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------

variable "block_volume_size_in_gbs" {
  description = "Size of the attached block volume in GBs."
  type        = number
  default     = 50
}

variable "block_volume_vpus_per_gb" {
  description = "Block volume VPU/GB performance level."
  type        = number
  default     = 10
}

# FSS is opt-in: default false because training tenancies often hit
# mount-target-count quota (console lab blocked mount targets).
variable "enable_file_storage" {
  description = "When true, create File Storage file system + mount target + export. Default false due to mount-target quota."
  type        = bool
  default     = false
}

variable "fss_export_path" {
  description = "NFS export path when enable_file_storage is true."
  type        = string
  default     = "/export"
}

variable "fss_export_source_cidr" {
  description = "Client CIDR allowed to mount the export."
  type        = string
  default     = "10.0.0.0/16"
}
