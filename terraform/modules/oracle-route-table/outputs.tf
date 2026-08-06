output "id" {
  description = "OCID of the route table."
  value       = oci_core_route_table.this.id
}

output "display_name" {
  description = "Display name of the route table."
  value       = oci_core_route_table.this.display_name
}
