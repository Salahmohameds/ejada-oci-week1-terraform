output "file_system_id" {
  description = "OCID of the file system when enabled."
  value       = try(oci_file_storage_file_system.this[0].id, null)
}

output "mount_target_id" {
  description = "OCID of the mount target when enabled."
  value       = try(oci_file_storage_mount_target.this[0].id, null)
}

output "mount_target_ip" {
  description = "Private IP of the mount target when enabled."
  value       = var.enable_fss ? data.oci_core_private_ip.mount_target[0].ip_address : null
}

output "export_id" {
  description = "OCID of the export when enabled."
  value       = try(oci_file_storage_export.this[0].id, null)
}

output "fss_export_path" {
  description = "NFS export path when enabled."
  value       = var.enable_fss ? var.fss_export_path : null
}
