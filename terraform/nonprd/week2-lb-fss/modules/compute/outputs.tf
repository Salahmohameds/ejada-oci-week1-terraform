output "instance_ids" {
  description = "Map of instance key (e.g. \"app\", \"jump\") to OCID."
  value       = { for key, inst in oci_core_instance.this : key => inst.id }
}

output "instance_private_ips" {
  description = "Map of instance key to private IP."
  value       = { for key, inst in oci_core_instance.this : key => inst.private_ip }
}

output "instance_public_ips" {
  description = "Map of instance key to public IP (null when assign_public_ip is false)."
  value       = { for key, inst in oci_core_instance.this : key => inst.public_ip }
}
