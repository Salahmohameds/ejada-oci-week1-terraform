output "id" {
  description = "OCID of the subnet."
  value       = oci_core_subnet.this.id
}

output "cidr_block" {
  description = "CIDR block of the subnet."
  value       = oci_core_subnet.this.cidr_block
}

output "display_name" {
  description = "Display name of the subnet."
  value       = oci_core_subnet.this.display_name
}

output "virtual_router_ip" {
  description = "Virtual router IP of the subnet."
  value       = oci_core_subnet.this.virtual_router_ip
}
