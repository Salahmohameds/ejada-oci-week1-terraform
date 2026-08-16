# ---------------------------------------------------------------------------
# Auth / provider
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
  description = "Tenancy OCID. Optional when using config_file_profile exclusively."
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
  description = "API key fingerprint for explicit API-key auth."
  type        = string
  default     = null
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the PEM private key for explicit API-key auth. Never commit the key."
  type        = string
  default     = null
  sensitive   = true
}

variable "compartment_ocid" {
  description = "Compartment OCID that owns the Terraform remote-state bucket."
  type        = string
}

# ---------------------------------------------------------------------------
# Bucket
# ---------------------------------------------------------------------------

variable "state_bucket_name" {
  description = "Object Storage bucket name that holds remote Terraform state for all nonprd stacks."
  type        = string
  default     = "w-terraform-state-intern18"
}

variable "enable_versioning" {
  description = "Enable Object Storage bucket versioning to protect state history (recommended)."
  type        = bool
  default     = true
}

variable "project_tag" {
  description = "Freeform Project tag value."
  type        = string
  default     = "Ejada-Cloud-Build"
}

variable "lab_tag" {
  description = "Freeform Lab tag value for this bootstrap stack."
  type        = string
  default     = "terraform-state-bootstrap"
}
