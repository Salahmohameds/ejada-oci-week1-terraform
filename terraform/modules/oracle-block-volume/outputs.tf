output "id" {
  description = "OCID of the block volume."
  value       = oci_core_volume.this.id
}

output "display_name" {
  description = "Display name of the block volume."
  value       = oci_core_volume.this.display_name
}

output "size_in_gbs" {
  description = "Size of the block volume in GBs."
  value       = oci_core_volume.this.size_in_gbs
}

output "availability_domain" {
  description = "Availability domain of the volume."
  value       = oci_core_volume.this.availability_domain
}

output "attachment_id" {
  description = "OCID of the volume attachment (null if not attached)."
  value       = try(oci_core_volume_attachment.this[0].id, null)
}

output "attachment_state" {
  description = "State of the volume attachment (null if not attached)."
  value       = try(oci_core_volume_attachment.this[0].state, null)
}
