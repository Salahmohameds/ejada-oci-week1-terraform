# IDs and kubectl hints. Null while enable_oke is false.

output "vcn_id" {
  description = "OCID of the Week 3 VCN."
  value       = module.network.vcn_id
}

output "subnet_ids" {
  description = "Map of subnet key => OCID (lb, workers, pods)."
  value       = { for k, m in module.subnet : k => m.subnet_id }
}

output "lb_subnet_id" {
  description = "Public subnet OCID for the OKE API endpoint and Service load balancers."
  value       = module.subnet["lb"].subnet_id
}

output "worker_subnet_id" {
  description = "Private worker subnet OCID."
  value       = module.subnet["workers"].subnet_id
}

output "pod_subnet_id" {
  description = "Private pod subnet OCID (VCN-native CNI)."
  value       = module.subnet["pods"].subnet_id
}

output "availability_domain" {
  description = "Availability domain used for the node pool."
  value       = local.availability_domain
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway when enabled."
  value       = module.network.service_gateway_id
}

output "log_group_id" {
  description = "Shared flow-log group OCID when any subnet has enable_logs."
  value       = module.network.log_group_id
}

output "oke_cluster_id" {
  description = "OCID of the OKE cluster when enable_oke is true."
  value       = try(module.oke[0].cluster_id, null)
}

output "oke_node_pool_id" {
  description = "OCID of the managed node pool when enable_oke is true."
  value       = try(module.oke[0].node_pool_id, null)
}

output "oke_cni_type" {
  description = "CNI type on the cluster."
  value       = var.enable_oke ? var.oke_cni_type : null
}

output "nsg_oke_api_id" {
  description = "OKE API NSG OCID when NSGs are enabled."
  value       = try(module.oke[0].nsg_api_id, null)
}

output "nsg_oke_workers_id" {
  description = "OKE worker NSG OCID when NSGs are enabled."
  value       = try(module.oke[0].nsg_workers_id, null)
}

output "nsg_oke_pods_id" {
  description = "OKE pod NSG OCID when VCN-native NSGs are enabled."
  value       = try(module.oke[0].nsg_pods_id, null)
}

output "kubernetes_version" {
  description = "Kubernetes version selected for the cluster."
  value       = var.enable_oke ? local.kubernetes_version : null
}

output "kubeconfig_hint" {
  description = "OCI CLI command to write kubeconfig after the cluster is ACTIVE."
  value = var.enable_oke ? format(
    "oci ce cluster create-kubeconfig --cluster-id %s --file $HOME/.kube/config --region %s --token-version 2.0.0 --kube-endpoint %s",
    try(module.oke[0].cluster_id, "<cluster-id>"),
    var.region,
    var.oke_endpoint_public ? "PUBLIC_ENDPOINT" : "PRIVATE_ENDPOINT"
  ) : null
}

output "k8s_namespace" {
  description = "Namespace used by k8s/ manifests."
  value       = var.k8s_namespace
}

output "k8s_apply_hint" {
  description = "Apply the demo workload after kubeconfig is set."
  value       = var.enable_oke ? "kubectl apply -f k8s/namespace.yaml -f k8s/storageclass.yaml -f k8s/pvc.yaml -f k8s/deployment.yaml -f k8s/service.yaml" : null
}
