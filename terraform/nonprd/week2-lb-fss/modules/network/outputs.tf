output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet."
  value       = oci_core_subnet.private.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway when enabled."
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "nsg_lb_id" {
  description = "OCID of the LB NSG when enabled."
  value       = try(oci_core_network_security_group.lb[0].id, null)
}

output "nsg_app_id" {
  description = "OCID of the app NSG when enabled."
  value       = try(oci_core_network_security_group.app[0].id, null)
}

output "nsg_mt_id" {
  description = "OCID of the mount-target NSG when enabled."
  value       = try(oci_core_network_security_group.mt[0].id, null)
}

output "nsg_lb_ids" {
  description = "LB NSG IDs for attachment (empty when disabled)."
  value       = var.enable_nsgs ? [oci_core_network_security_group.lb[0].id] : []
}

output "nsg_app_ids" {
  description = "App NSG IDs for attachment (empty when disabled)."
  value       = var.enable_nsgs ? [oci_core_network_security_group.app[0].id] : []
}

output "nsg_mt_ids" {
  description = "Mount-target NSG IDs for attachment (empty when disabled)."
  value       = var.enable_nsgs && var.enable_fss ? [oci_core_network_security_group.mt[0].id] : []
}
