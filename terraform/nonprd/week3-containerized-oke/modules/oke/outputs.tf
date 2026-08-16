output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_name" {
  description = "Name of the OKE cluster."
  value       = oci_containerengine_cluster.this.name
}

output "node_pool_id" {
  description = "OCID of the managed node pool."
  value       = oci_containerengine_node_pool.this.id
}

output "kubernetes_version" {
  description = "Kubernetes version on the cluster."
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "cni_type" {
  description = "CNI type configured on the cluster."
  value       = var.cni_type
}

output "endpoints" {
  description = "Cluster endpoints (public/private) when populated."
  value       = try(oci_containerengine_cluster.this.endpoints, null)
}

output "nsg_api_id" {
  description = "API endpoint NSG OCID when enable_nsgs is true."
  value       = try(oci_core_network_security_group.this["api"].id, null)
}

output "nsg_workers_id" {
  description = "Worker NSG OCID when enable_nsgs is true."
  value       = try(oci_core_network_security_group.this["workers"].id, null)
}

output "nsg_pods_id" {
  description = "Pod NSG OCID when VCN-native NSGs are enabled."
  value       = try(oci_core_network_security_group.this["pods"].id, null)
}
