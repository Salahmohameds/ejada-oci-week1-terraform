# Root versions. Pin Terraform >= 1.5 and the OCI provider (~> 6.0).
# The lockfile records the applied provider (6.37.0).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}
