output "namespace" {
  description = "Object Storage namespace for this tenancy. Needed to fill the `endpoint` in each stack's backend.tf / backend.hcl."
  value       = data.oci_objectstorage_namespace.this.namespace
}

output "state_bucket_name" {
  description = "Name of the Terraform remote-state bucket."
  value       = oci_objectstorage_bucket.terraform_state.name
}

output "state_bucket_id" {
  description = "OCID of the Terraform remote-state bucket."
  value       = oci_objectstorage_bucket.terraform_state.id
}

output "s3_compatible_endpoint" {
  description = "S3-compatible Object Storage endpoint for the `s3` backend `endpoint` argument."
  value       = "https://${data.oci_objectstorage_namespace.this.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}
