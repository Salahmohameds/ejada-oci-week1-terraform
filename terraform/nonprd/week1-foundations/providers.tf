# ---------------------------------------------------------------------------
# Authentication (choose ONE approach)
# ---------------------------------------------------------------------------
#
# RECOMMENDED for interns — OCI CLI config profile (~/.oci/config):
#
#   provider "oci" {
#     region              = var.region
#     config_file_profile = var.config_file_profile  # usually "DEFAULT"
#   }
#
# ALTERNATIVE — explicit API key variables (never commit real values):
#
#   provider "oci" {
#     tenancy_ocid     = var.tenancy_ocid
#     user_ocid        = var.user_ocid
#     fingerprint      = var.fingerprint
#     private_key_path = var.private_key_path
#     region           = var.region
#   }
#
# Do not hardcode PEM paths or secrets in committed files. Use
# terraform.tfvars (gitignored) or environment variables only locally.
# ---------------------------------------------------------------------------

provider "oci" {
  region              = var.region
  config_file_profile = var.config_file_profile

  # Uncomment the block below (and set variables) only if you are NOT using
  # config_file_profile / ~/.oci/config. Leave nulls when using the profile.
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
