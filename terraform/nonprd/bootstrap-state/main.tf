# Remote-state bucket for the nonprd Terraform stacks (week2-lb-fss,
# week3-containerized-oke, ...). Object Storage exposes an S3-compatible API,
# so downstream stacks point the standard `s3` backend at this bucket's
# S3-compatible endpoint instead of writing local terraform.tfstate files.

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "terraform_state" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = var.state_bucket_name
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = var.enable_versioning ? "Enabled" : "Disabled"

  freeform_tags = {
    Project = var.project_tag
    Lab     = var.lab_tag
  }
}
