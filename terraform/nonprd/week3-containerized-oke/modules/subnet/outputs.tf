output "subnet_id" {
  description = "OCID of the subnet."
  value       = oci_core_subnet.this.id
}

output "subnet_cidr" {
  description = "CIDR of the subnet."
  value       = oci_core_subnet.this.cidr_block
}

output "route_table_id" {
  description = "OCID of the subnet route table."
  value       = oci_core_route_table.this.id
}

output "security_list_id" {
  description = "OCID of the subnet security list."
  value       = oci_core_security_list.this.id
}

output "log_group_id" {
  description = "Log group OCID used by this subnet (created or passed in)."
  value       = local.log_group_id
}

output "log_id" {
  description = "Flow log OCID when enable_logs is true."
  value       = try(oci_logging_log.flow[0].id, null)
}

output "capture_filter_id" {
  description = "Capture filter OCID when flow logs are enabled."
  value       = local.capture_filter_id
}

output "prohibit_public_ip_on_vnic" {
  description = "Whether public IPs are prohibited on VNICs."
  value       = oci_core_subnet.this.prohibit_public_ip_on_vnic
}
