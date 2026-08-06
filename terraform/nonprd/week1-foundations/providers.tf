# Prefer config_file_profile (~/.oci/config). Optional API-key vars stay null
# when using a CLI profile; never commit real PEM paths or tenancy secrets.

provider "oci" {
  region              = var.region
  config_file_profile = var.config_file_profile

  # Only needed when not using config_file_profile.
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
