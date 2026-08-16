variable "compartment_ocid" {
  description = "Compartment OCID for the cluster, node pool, and optional NSGs."
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID that hosts the cluster."
  type        = string
}

variable "cluster_name" {
  description = "OKE cluster display name."
  type        = string
}

variable "cluster_type" {
  description = "BASIC_CLUSTER (lab) or ENHANCED_CLUSTER."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version string (e.g. v1.31.1)."
  type        = string
}

variable "cni_type" {
  description = "Pod CNI. Lab uses OCI_VCN_IP_NATIVE (VCN-native pod networking)."
  type        = string
}

variable "endpoint_public" {
  description = "Assign a public IP to the Kubernetes API endpoint."
  type        = bool
}

variable "endpoint_subnet_id" {
  description = "Subnet OCID for the Kubernetes API endpoint."
  type        = string
}

variable "worker_subnet_id" {
  description = "Subnet OCID for managed worker nodes."
  type        = string
}

variable "pod_subnet_ids" {
  description = "Pod subnet OCIDs (required when cni_type is OCI_VCN_IP_NATIVE)."
  type        = list(string)
  default     = []
}

variable "service_lb_subnet_id" {
  description = "Public subnet OCID for Kubernetes Service load balancers."
  type        = string
}

variable "services_cidr" {
  description = "Kubernetes Service CIDR (must not overlap the VCN)."
  type        = string
}

variable "pods_cidr" {
  description = "Overlay pod CIDR used only when cni_type is FLANNEL_OVERLAY."
  type        = string
  default     = "10.244.0.0/16"
}

variable "dashboard_enabled" {
  description = "Enable the OKE Kubernetes dashboard add-on."
  type        = bool
  default     = false
}

variable "availability_domain" {
  description = "Availability domain for node pool placement."
  type        = string
}

variable "node_pool_name" {
  description = "Managed node pool display name."
  type        = string
}

variable "node_pool_size" {
  description = "Worker node count."
  type        = number
}

variable "node_shape" {
  description = "Worker node shape."
  type        = string
}

variable "node_ocpus" {
  description = "OCPUs per flex worker."
  type        = number
}

variable "node_memory_in_gbs" {
  description = "Memory (GB) per flex worker."
  type        = number
}

variable "node_boot_volume_size_in_gbs" {
  description = "Worker boot volume size (GB)."
  type        = number
}

variable "node_image_id" {
  description = "OKE-compatible node image OCID."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key placed on worker nodes."
  type        = string
  sensitive   = true
}

variable "max_pods_per_node" {
  description = "Max pods per worker (VCN-native). Limited by shape VNICs."
  type        = number
  default     = 31
}

variable "freeform_tags" {
  description = "Freeform tags for OKE resources."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for OKE resources."
  type        = map(string)
  default     = {}
}

# --- Optional NSGs (same related-group as the cluster; see nsg.tf) ---

variable "enable_nsgs" {
  description = "Create and attach NSGs for API endpoint, workers, and pods."
  type        = bool
  default     = true
}

variable "nsg_api_display_name" {
  description = "API endpoint NSG display name."
  type        = string
}

variable "nsg_workers_display_name" {
  description = "Worker NSG display name."
  type        = string
}

variable "nsg_pods_display_name" {
  description = "Pod NSG display name (VCN-native)."
  type        = string
}

variable "worker_subnet_cidr" {
  description = "Worker subnet CIDR (NSG sources)."
  type        = string
}

variable "pod_subnet_cidr" {
  description = "Pod subnet CIDR (NSG sources)."
  type        = string
}

variable "lb_subnet_cidr" {
  description = "Service-LB / API subnet CIDR (NSG sources)."
  type        = string
}

variable "allowed_api_cidr" {
  description = "Client CIDR allowed to reach the Kubernetes API (prefer YOUR_IP/32)."
  type        = string
}

variable "api_port" {
  description = "Kubernetes API TCP port."
  type        = number
  default     = 6443
}

variable "oke_control_port" {
  description = "OKE control/proxy TCP port on the API endpoint."
  type        = number
  default     = 12250
}

variable "kubelet_port" {
  description = "Kubelet TCP port on workers."
  type        = number
  default     = 10250
}

variable "app_port" {
  description = "Application / NodePort target used by the Service LB."
  type        = number
  default     = 80
}

variable "node_port_min" {
  description = "NodePort range start (Service LB health / traffic)."
  type        = number
  default     = 30000
}

variable "node_port_max" {
  description = "NodePort range end."
  type        = number
  default     = 32767
}
