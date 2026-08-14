output "app_instance_id" {
  description = "OCID of the private app instance."
  value       = oci_core_instance.app.id
}

output "app_instance_private_ip" {
  description = "Private IP of the app instance."
  value       = oci_core_instance.app.private_ip
}

output "jump_instance_id" {
  description = "OCID of the jump host when enable_jump is true."
  value       = try(oci_core_instance.jump[0].id, null)
}

output "jump_instance_public_ip" {
  description = "Public IP of the jump host when enable_jump is true."
  value       = try(oci_core_instance.jump[0].public_ip, null)
}
