output "id" {
  description = "OCID of the compute instance."
  value       = oci_core_instance.this.id
}

output "display_name" {
  description = "Display name of the instance."
  value       = oci_core_instance.this.display_name
}

output "private_ip" {
  description = "Primary private IP of the instance."
  value       = oci_core_instance.this.private_ip
}

output "public_ip" {
  description = "Ephemeral public IP on the instance (null when none / reserved IP used instead)."
  value       = oci_core_instance.this.public_ip
}

output "primary_vnic_id" {
  description = "OCID of the instance primary VNIC (for reserved public IP assignment)."
  value       = local.primary_vnic_attachment.vnic_id
}

output "availability_domain" {
  description = "Availability domain of the instance."
  value       = oci_core_instance.this.availability_domain
}

output "image_id" {
  description = "OCID of the boot image used."
  value       = local.image_id
}

output "boot_volume_id" {
  description = "OCID of the boot volume."
  value       = oci_core_instance.this.boot_volume_id
}

output "state" {
  description = "Lifecycle state of the instance."
  value       = oci_core_instance.this.state
}
