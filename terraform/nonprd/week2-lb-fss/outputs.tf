output "vcn_id" {
  description = "OCID of the Week 2 VCN."
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet (ALB)."
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet (app + FSS MT)."
  value       = oci_core_subnet.private.id
}

output "availability_domain" {
  description = "Availability domain used for compute and FSS."
  value       = local.availability_domain
}

output "app_instance_id" {
  description = "OCID of the private app instance."
  value       = oci_core_instance.app.id
}

output "app_instance_private_ip" {
  description = "Private IP of the app instance (LB backend)."
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

output "file_system_id" {
  description = "OCID of the file system when enable_fss is true."
  value       = try(oci_file_storage_file_system.app[0].id, null)
}

output "mount_target_id" {
  description = "OCID of the mount target when enable_fss is true."
  value       = try(oci_file_storage_mount_target.app[0].id, null)
}

output "mount_target_ip" {
  description = "Private IP of the mount target when enable_fss is true."
  value       = var.enable_fss ? local.mount_target_ip : null
}

output "fss_export_path" {
  description = "NFS export path when enable_fss is true."
  value       = var.enable_fss ? var.fss_export_path : null
}

output "lb_id" {
  description = "OCID of the flexible application load balancer."
  value       = oci_load_balancer_load_balancer.app.id
}

output "lb_public_ip" {
  description = "Public IP of the load balancer (browser / curl target)."
  value       = try(oci_load_balancer_load_balancer.app.ip_address_details[0].ip_address, null)
}

output "lb_url" {
  description = "HTTP URL for the lab application via the ALB."
  value       = "http://${try(oci_load_balancer_load_balancer.app.ip_address_details[0].ip_address, "PENDING")}"
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway when enable_service_gateway is true."
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "nsg_lb_id" {
  description = "OCID of the LB NSG when enable_nsgs is true."
  value       = try(oci_core_network_security_group.lb[0].id, null)
}

output "nsg_app_id" {
  description = "OCID of the app NSG when enable_nsgs is true."
  value       = try(oci_core_network_security_group.app[0].id, null)
}

output "nsg_mt_id" {
  description = "OCID of the mount-target NSG when enable_nsgs and enable_fss are true."
  value       = try(oci_core_network_security_group.mt[0].id, null)
}

output "bastion_id" {
  description = "OCID of the Bastion service when enable_bastion is true and create succeeded."
  value       = length(oci_bastion_bastion.this) > 0 ? oci_bastion_bastion.this[0].id : null
}

output "bastion_name" {
  description = "Bastion name when create succeeded."
  value       = length(oci_bastion_bastion.this) > 0 ? oci_bastion_bastion.this[0].name : null
}

output "bastion_private_endpoint_ip" {
  description = "Bastion private endpoint IP (if populated for this type)."
  value       = length(oci_bastion_bastion.this) > 0 ? oci_bastion_bastion.this[0].private_endpoint_ip_address : null
}

output "bastion_session_create_hint" {
  description = "Example OCI CLI managed SSH session create against the private app."
  value = length(oci_bastion_bastion.this) > 0 ? format(
    "oci bastion session create-managed-ssh --bastion-id %s --target-resource-id %s --target-os-username opc --target-private-key-file <path-to-private-key> --ssh-public-key-file <path-to-public-key> --session-ttl 1800 --wait-for-state SUCCEEDED",
    oci_bastion_bastion.this[0].id,
    oci_core_instance.app.id
  ) : (var.enable_bastion ? "Bastion enabled in config but not in state — CreateBastion needs bastion-family IAM (or set enable_bastion=false)." : null)
}

output "ssh_jump_hint" {
  description = "SSH example for jump host when enable_jump is true."
  value = var.enable_jump ? format(
    "ssh -i <path-to-private-key> opc@%s",
    try(oci_core_instance.jump[0].public_ip, "<jump-public-ip>")
  ) : "enable_jump is false — use OCI Bastion (bastion_session_create_hint) for private SSH"
}

output "ssh_private_via_jump_hint" {
  description = "ProxyJump-style SSH to the private app (when jump is enabled)."
  value = var.enable_jump ? format(
    "ssh -i <path-to-private-key> -J opc@%s opc@%s",
    try(oci_core_instance.jump[0].public_ip, "<jump-ip>"),
    oci_core_instance.app.private_ip
  ) : null
}
