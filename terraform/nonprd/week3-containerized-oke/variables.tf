# All changeable arguments live here. Values belong in terraform.tfvars
# (gitignored). This file is the contract; terraform.tfvars.example is the template.

# ---------------------------------------------------------------------------
# Auth / provider
# ---------------------------------------------------------------------------

variable "region" {
  description = "OCI region home for this stack."
  type        = string
  default     = "me-jeddah-1"
}

variable "config_file_profile" {
  description = "Profile name from ~/.oci/config used by the OCI provider."
  type        = string
  default     = "DEFAULT"
}

variable "tenancy_ocid" {
  description = "Tenancy OCID. Optional when using config_file_profile exclusively."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_ocid" {
  description = "User OCID for explicit API-key auth. Leave null when using config_file_profile."
  type        = string
  default     = null
  sensitive   = true
}

variable "fingerprint" {
  description = "API key fingerprint for explicit API-key auth."
  type        = string
  default     = null
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the PEM private key for explicit API-key auth. Never commit the key."
  type        = string
  default     = null
  sensitive   = true
}

variable "compartment_ocid" {
  description = "Compartment OCID where Week 3 resources are created."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming / tags
# ---------------------------------------------------------------------------

variable "name_prefix" {
  description = "Short prefix for resource display names (e.g. w3)."
  type        = string
  default     = "w3"
}

variable "project_tag" {
  description = "Freeform Project tag value."
  type        = string
  default     = "Ejada-Cloud-Build"
}

variable "lab_tag" {
  description = "Freeform Lab tag value."
  type        = string
  default     = "week3"
}

variable "defined_tags" {
  description = "Defined tags (namespace.key = value). Empty unless the tenancy has tag namespaces ready."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Feature flags
# ---------------------------------------------------------------------------

variable "enable_oke" {
  description = "Create the OKE cluster + managed node pool. Keep false until a cleanup window exists."
  type        = bool
  default     = false
}

variable "enable_service_gateway" {
  description = "Create a Service Gateway and add All-OSN routes on NAT-routed subnets."
  type        = bool
  default     = true
}

variable "enable_oke_nsgs" {
  description = "Create API / worker / pod NSGs inside the OKE module and attach them."
  type        = bool
  default     = true
}

variable "enable_https_ingress" {
  description = "Allow TCP/443 from the internet on the public (lb) security list."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

variable "vcn_cidr" {
  description = "CIDR block for the Week 3 VCN (avoid week1 10.0 / week2 10.1)."
  type        = string
  default     = "10.2.0.0/16"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (letters/digits, max 15)."
  type        = string
  default     = "w3vcn"
}

variable "vcn_display_name" {
  description = "VCN display name. Empty uses name_prefix-vcn."
  type        = string
  default     = ""
}

variable "igw_display_name" {
  description = "Internet gateway display name. Empty uses name_prefix-igw."
  type        = string
  default     = ""
}

variable "nat_display_name" {
  description = "NAT gateway display name. Empty uses name_prefix-nat."
  type        = string
  default     = ""
}

variable "sgw_display_name" {
  description = "Service gateway display name. Empty uses name_prefix-sgw."
  type        = string
  default     = ""
}

variable "log_group_display_name" {
  description = "Shared VCN flow-log group name. Empty uses name_prefix-vcn-logs. Created only when a subnet has enable_logs."
  type        = string
  default     = ""
}

variable "subnets" {
  description = "Map of subnets. Each key becomes module.subnet[key] (subnet + RT + SL + optional flow log). Required keys: lb, workers, pods."
  type = map(object({
    display_name               = optional(string, "")
    cidr                       = string
    dns_label                  = string
    prohibit_public_ip_on_vnic = bool
    route_type                 = string
    enable_logs                = optional(bool, false)
  }))
  # lb is public: API endpoint + Service LB VIPs need an IGW path.
  # pods is /18: VCN-native CNI burns a VCN IP per pod (~31/node).
  # enable_logs on lb: north-south flow logs without standing up OKE.
  default = {
    lb = {
      display_name               = ""
      cidr                       = "10.2.1.0/24"
      dns_label                  = "w3lb"
      prohibit_public_ip_on_vnic = false
      route_type                 = "igw"
      enable_logs                = true
    }
    workers = {
      display_name               = ""
      cidr                       = "10.2.10.0/24"
      dns_label                  = "w3workers"
      prohibit_public_ip_on_vnic = true
      route_type                 = "nat"
      enable_logs                = false
    }
    pods = {
      display_name               = ""
      cidr                       = "10.2.128.0/18"
      dns_label                  = "w3pods"
      prohibit_public_ip_on_vnic = true
      route_type                 = "nat"
      enable_logs                = false
    }
  }

  validation {
    condition = alltrue([
      contains(keys(var.subnets), "lb"),
      contains(keys(var.subnets), "workers"),
      contains(keys(var.subnets), "pods"),
    ])
    error_message = "subnets must include keys lb, workers, and pods (VCN-native OKE)."
  }

  validation {
    condition     = alltrue([for s in values(var.subnets) : contains(["igw", "nat"], s.route_type)])
    error_message = "Each subnet route_type must be igw or nat."
  }
}

variable "allowed_ssh_cidr" {
  description = "Client CIDR for SSH on workers and Kubernetes API (prefer YOUR_PUBLIC_IP/32)."
  type        = string
}

variable "app_port" {
  description = "HTTP port for the demo app / Service LB."
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port allowed on the public lb security list when enable_https_ingress is true."
  type        = number
  default     = 443
}

variable "kubernetes_api_port" {
  description = "Kubernetes API TCP port on the public endpoint."
  type        = number
  default     = 6443
}

variable "oke_control_port" {
  description = "OKE control/proxy TCP port (API endpoint)."
  type        = number
  default     = 12250
}

variable "kubelet_port" {
  description = "Kubelet TCP port on workers."
  type        = number
  default     = 10250
}

variable "node_port_min" {
  description = "NodePort range start for Service LB traffic to workers."
  type        = number
  default     = 30000
}

variable "node_port_max" {
  description = "NodePort range end for Service LB traffic to workers."
  type        = number
  default     = 32767
}

variable "log_retention_duration" {
  description = "Flow log retention (days) when a subnet has enable_logs."
  type        = number
  default     = 30
}

variable "flow_log_sampling_rate" {
  description = "Capture-filter sampling rate for subnet flow logs (1, 10, 50, or 100)."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------
# OKE
# ---------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "SSH public key contents for node metadata. Set in terraform.tfvars only."
  type        = string
  default     = ""
  sensitive   = true
}

variable "availability_domain_index" {
  description = "Zero-based index into data.oci_identity_availability_domains for the region."
  type        = number
  default     = 0
}

variable "oke_cluster_display_name" {
  description = "OKE cluster name. Empty uses name_prefix-oke."
  type        = string
  default     = ""
}

variable "oke_cluster_type" {
  description = "OKE cluster type: BASIC_CLUSTER (lab) or ENHANCED_CLUSTER."
  type        = string
  default     = "BASIC_CLUSTER"
}

variable "oke_cni_type" {
  description = "Pod CNI. Lab requires OCI_VCN_IP_NATIVE (VCN-native pod networking)."
  type        = string
  default     = "OCI_VCN_IP_NATIVE"
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. v1.31.1). Empty selects the latest from cluster_option."
  type        = string
  default     = ""
}

variable "oke_endpoint_public" {
  description = "Expose the Kubernetes API with a public IP (intern kubectl from a laptop)."
  type        = bool
  default     = true
}

variable "oke_pods_cidr" {
  description = "Flannel overlay pod CIDR only. Unused for OCI_VCN_IP_NATIVE."
  type        = string
  default     = "10.244.0.0/16"
}

variable "oke_services_cidr" {
  description = "Kubernetes Service CIDR (must not overlap the VCN)."
  type        = string
  default     = "10.96.0.0/16"
}

variable "oke_dashboard_enabled" {
  description = "Enable the OKE Kubernetes dashboard add-on."
  type        = bool
  default     = false
}

variable "oke_node_pool_display_name" {
  description = "Node pool name. Empty uses name_prefix-np."
  type        = string
  default     = ""
}

variable "oke_node_pool_size" {
  description = "Managed worker node count. Default 1 for intern quota."
  type        = number
  default     = 1
}

variable "oke_node_shape" {
  description = "Worker node shape. VM.Standard.E4.Flex or VM.Standard.A1.Flex."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "oke_node_ocpus" {
  description = "OCPUs per worker (flex shapes)."
  type        = number
  default     = 1
}

variable "oke_node_memory_in_gbs" {
  description = "Memory (GB) per worker (flex shapes)."
  type        = number
  default     = 8
}

variable "oke_node_boot_volume_size_in_gbs" {
  description = "Boot volume size (GB) for worker nodes."
  type        = number
  default     = 50
}

variable "oke_node_image_id" {
  description = "OKE-compatible node image OCID. Empty looks up from node_pool_option sources."
  type        = string
  default     = ""
}

variable "oke_max_pods_per_node" {
  description = "Max pods per worker for VCN-native CNI."
  type        = number
  default     = 31
}

variable "nsg_oke_api_display_name" {
  description = "OKE API NSG display name. Empty uses name_prefix-nsg-oke-api."
  type        = string
  default     = ""
}

variable "nsg_oke_workers_display_name" {
  description = "OKE worker NSG display name. Empty uses name_prefix-nsg-oke-workers."
  type        = string
  default     = ""
}

variable "nsg_oke_pods_display_name" {
  description = "OKE pod NSG display name. Empty uses name_prefix-nsg-oke-pods."
  type        = string
  default     = ""
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the demo workload (manifests under k8s/)."
  type        = string
  default     = "w3-demo"
}
