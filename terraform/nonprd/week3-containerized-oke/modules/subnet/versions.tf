# Inherit the root OCI provider; no extra version pin in the child module.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
