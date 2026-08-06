output "vcn_id" {
  description = "OCID of the Week 1 VCN."
  value       = module.vcn.vcn_id
}

output "internet_gateway_id" {
  description = "OCID of the internet gateway."
  value       = module.internet_gateway.id
}

output "public_route_table_id" {
  description = "OCID of the public route table (0.0.0.0/0 → IGW)."
  value       = module.public_route_table.id
}

output "private_route_table_id" {
  description = "OCID of the private route table (no IGW routes)."
  value       = module.private_route_table.id
}

output "public_security_list_id" {
  description = "OCID of the public security list."
  value       = module.public_security_list.id
}

output "private_security_list_id" {
  description = "OCID of the private security list."
  value       = module.private_security_list.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = module.public_subnet.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet."
  value       = module.private_subnet.id
}

output "availability_domain" {
  description = "Availability domain used for compute and block storage."
  value       = local.availability_domain
}

output "instance_id" {
  description = "OCID of the Linux compute instance."
  value       = module.instance.id
}

output "instance_display_name" {
  description = "Display name of the compute instance."
  value       = module.instance.display_name
}

output "instance_private_ip" {
  description = "Private IP of the compute instance."
  value       = module.instance.private_ip
}

output "instance_public_ip" {
  description = "Public IP used to reach the instance (reserved if enabled, else ephemeral)."
  value       = var.use_reserved_public_ip ? module.reserved_public_ip[0].ip_address : module.instance.public_ip
}

output "reserved_public_ip" {
  description = "Reserved (static) public IP address when use_reserved_public_ip is true; null otherwise."
  value       = var.use_reserved_public_ip ? module.reserved_public_ip[0].ip_address : null
}

output "reserved_public_ip_id" {
  description = "OCID of the reserved public IP resource when enabled; null otherwise."
  value       = var.use_reserved_public_ip ? module.reserved_public_ip[0].id : null
}

output "block_volume_id" {
  description = "OCID of the attached block volume."
  value       = module.block_volume.id
}

output "block_volume_attachment_id" {
  description = "OCID of the block volume attachment."
  value       = module.block_volume.attachment_id
}

output "file_system_id" {
  description = "OCID of the file system when enable_file_storage is true."
  value       = try(module.file_storage[0].file_system_id, null)
}

output "mount_target_id" {
  description = "OCID of the mount target when enable_file_storage is true."
  value       = try(module.file_storage[0].mount_target_id, null)
}

output "fss_export_path" {
  description = "NFS export path when enable_file_storage is true."
  value       = try(module.file_storage[0].export_path, null)
}

output "ssh_hint" {
  description = "Example SSH command after apply (replace key path)."
  value       = "ssh -i <path-to-private-key> opc@${var.use_reserved_public_ip ? module.reserved_public_ip[0].ip_address : module.instance.public_ip}"
}
