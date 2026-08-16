# Root versions. Pin Terraform >= 1.5 and the OCI provider (~> 6.0), matching
# the other stacks in this repo.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}
