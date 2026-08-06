output "id" {
  description = "OCID of the public IP resource."
  value       = oci_core_public_ip.this.id
}

output "ip_address" {
  description = "The public IPv4 address."
  value       = oci_core_public_ip.this.ip_address
}

output "display_name" {
  description = "Display name of the public IP."
  value       = oci_core_public_ip.this.display_name
}

output "lifetime" {
  description = "Lifetime of the public IP (RESERVED or EPHEMERAL)."
  value       = oci_core_public_ip.this.lifetime
}

output "private_ip_id" {
  description = "OCID of the private IP this public IP is assigned to."
  value       = oci_core_public_ip.this.private_ip_id
}

output "state" {
  description = "Lifecycle state of the public IP."
  value       = oci_core_public_ip.this.state
}
