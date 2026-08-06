output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "default_route_table_id" {
  description = "OCID of the VCN default route table."
  value       = oci_core_vcn.this.default_route_table_id
}

output "default_security_list_id" {
  description = "OCID of the VCN default security list."
  value       = oci_core_vcn.this.default_security_list_id
}

output "default_dhcp_options_id" {
  description = "OCID of the VCN default DHCP options."
  value       = oci_core_vcn.this.default_dhcp_options_id
}

output "cidr_blocks" {
  description = "CIDR blocks configured on the VCN."
  value       = oci_core_vcn.this.cidr_blocks
}

output "display_name" {
  description = "Display name of the VCN."
  value       = oci_core_vcn.this.display_name
}
