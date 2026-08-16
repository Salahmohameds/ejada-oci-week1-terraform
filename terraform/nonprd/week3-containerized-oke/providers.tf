# OCI provider. Prefer config_file_profile (~/.oci/config). Optional API-key
# vars stay null when using a CLI profile; never commit real PEM paths.

provider "oci" {
  region              = var.region
  config_file_profile = var.config_file_profile

  # Interns cannot write Oracle-Tags (CreatedBy/CreatedOn). Empty defined_tags
  # would otherwise try to strip them on the next apply.
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]

  # Only needed when not using config_file_profile.
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
