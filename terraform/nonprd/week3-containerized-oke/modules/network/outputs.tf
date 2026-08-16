output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway."
  value       = oci_core_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway."
  value       = oci_core_nat_gateway.this.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway when enable_service_gateway is true."
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "log_group_id" {
  description = "Shared flow-log group OCID when enable_log_group is true."
  value       = try(oci_logging_log_group.vcn_flow[0].id, null)
}

output "osn_cidr" {
  description = "All-OSN service CIDR for extra private-subnet route rules."
  value       = try(local.osn_service.cidr_block, null)
}
