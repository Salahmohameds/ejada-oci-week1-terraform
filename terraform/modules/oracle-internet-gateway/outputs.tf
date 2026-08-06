output "id" {
  description = "OCID of the internet gateway."
  value       = oci_core_internet_gateway.this.id
}

output "display_name" {
  description = "Display name of the internet gateway."
  value       = oci_core_internet_gateway.this.display_name
}
