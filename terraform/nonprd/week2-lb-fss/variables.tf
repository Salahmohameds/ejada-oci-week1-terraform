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
  description = "Compartment OCID where Week 2 Lab 2 resources are created."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming / tags
# ---------------------------------------------------------------------------

variable "name_prefix" {
  description = "Short prefix for resource display names (e.g. w2)."
  type        = string
  default     = "w2"
}

variable "project_tag" {
  description = "Freeform Project tag value."
  type        = string
  default     = "Ejada-Cloud-Build"
}

variable "lab_tag" {
  description = "Freeform Lab tag value."
  type        = string
  default     = "week2-lab2"
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (ALB, optional jump)."
  type        = string
  default     = "10.1.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet (app VM, FSS mount target)."
  type        = string
  default     = "10.1.2.0/24"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN (letters/digits, max 15)."
  type        = string
  default     = "w2vcn"
}

variable "public_subnet_dns_label" {
  description = "DNS label for the public subnet."
  type        = string
  default     = "public"
}

variable "private_subnet_dns_label" {
  description = "DNS label for the private subnet."
  type        = string
  default     = "private"
}

variable "vcn_display_name" {
  description = "VCN display name override. Empty uses name_prefix-vcn."
  type        = string
  default     = ""
}

variable "igw_display_name" {
  description = "Internet gateway display name override. Empty uses name_prefix-igw."
  type        = string
  default     = ""
}

variable "nat_display_name" {
  description = "NAT gateway display name override. Empty uses name_prefix-nat."
  type        = string
  default     = ""
}

variable "public_rt_display_name" {
  description = "Public route table display name override."
  type        = string
  default     = ""
}

variable "private_rt_display_name" {
  description = "Private route table display name override."
  type        = string
  default     = ""
}

variable "public_sl_display_name" {
  description = "Public security list display name override."
  type        = string
  default     = ""
}

variable "private_sl_display_name" {
  description = "Private security list display name override."
  type        = string
  default     = ""
}

variable "public_subnet_display_name" {
  description = "Public subnet display name override."
  type        = string
  default     = ""
}

variable "private_subnet_display_name" {
  description = "Private subnet display name override."
  type        = string
  default     = ""
}

variable "sgw_display_name" {
  description = "Service gateway display name override. Empty uses name_prefix-sgw."
  type        = string
  default     = ""
}

variable "enable_service_gateway" {
  description = "Create Service Gateway + private RT route for All region Services in OSN."
  type        = bool
  default     = true
}

variable "nsg_lb_display_name" {
  description = "LB NSG display name override. Empty uses name_prefix-nsg-lb."
  type        = string
  default     = ""
}

variable "nsg_app_display_name" {
  description = "App NSG display name override. Empty uses name_prefix-nsg-app."
  type        = string
  default     = ""
}

variable "nsg_mt_display_name" {
  description = "Mount target NSG display name override. Empty uses name_prefix-nsg-mt."
  type        = string
  default     = ""
}

variable "enable_nsgs" {
  description = "Create NSGs and attach to LB, app VNIC, and mount target (SLs remain)."
  type        = bool
  default     = true
}

# No default — force an explicit /32 (or lab CIDR) in terraform.tfvars.
variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH (jump SL) and Bastion client_cidr_block_allow_list. Prefer YOUR_PUBLIC_IP/32."
  type        = string
}

variable "app_port" {
  description = "HTTP port served by the private app and LB listener/backends."
  type        = number
  default     = 80
}

variable "enable_https_ingress" {
  description = "Allow TCP/443 from the internet on the public security list and LB NSG."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Bastion service (secure access to private app)
# ---------------------------------------------------------------------------

variable "enable_bastion" {
  description = "Create OCI Bastion service for private instance SSH (PDF secure-access model)."
  type        = bool
  default     = true
}

variable "bastion_name" {
  description = "Bastion display name override. Empty uses name_prefix-bastion."
  type        = string
  default     = ""
}

variable "bastion_type" {
  description = "Bastion type: PUBLIC (lab-friendly) or STANDARD (private endpoint)."
  type        = string
  default     = "PUBLIC"
}

variable "bastion_max_session_ttl_in_seconds" {
  description = "Maximum session TTL for the bastion (seconds). OCI default upper bound is 10800 (3h)."
  type        = number
  default     = 10800
}

variable "bastion_client_cidr_block_allow_list" {
  description = "Client CIDRs allowed to use the bastion. Empty uses [allowed_ssh_cidr]."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "SSH public key content placed on instances (ssh-ed25519 / ssh-rsa line)."
  type        = string
  sensitive   = true
}

variable "availability_domain_index" {
  description = "Zero-based index into data.oci_identity_availability_domains for the region."
  type        = number
  default     = 0
}

variable "instance_shape" {
  description = "Compute shape for the private app instance (and jump if enabled)."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "OCPUs for flexible shapes (app instance)."
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memory (GB) for flexible shapes (app instance)."
  type        = number
  default     = 8
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size (GB) for instances."
  type        = number
  default     = 50
}

variable "image_operating_system" {
  description = "OS name for the image data source."
  type        = string
  default     = "Oracle Linux"
}

variable "image_operating_system_version" {
  description = "OS version for the image data source."
  type        = string
  default     = "9"
}

variable "app_instance_display_name" {
  description = "Private app instance display name override."
  type        = string
  default     = ""
}

variable "app_hostname_label" {
  description = "Hostname label for the private app instance VNIC."
  type        = string
  default     = "appvm"
}

variable "app_mount_path" {
  description = "Local directory where FSS is mounted on the app instance."
  type        = string
  default     = "/mnt/app"
}

variable "app_index_html_body" {
  description = "HTML body written to the FSS mount as index.html via cloud-init."
  type        = string
  default     = "<!DOCTYPE html><html><head><title>Week 2 Lab 2</title></head><body><h1>Week 2 Lab 2 - LB + FSS</h1><p>Served from OCI File Storage via private app and public ALB.</p></body></html>"
}

variable "enable_jump" {
  description = "Create a public jump host for SSH debugging. Default false — stack works with cloud-init only."
  type        = bool
  default     = false
}

variable "jump_instance_display_name" {
  description = "Jump host display name override."
  type        = string
  default     = ""
}

variable "jump_hostname_label" {
  description = "Hostname label for the jump host VNIC."
  type        = string
  default     = "jump"
}

variable "jump_ocpus" {
  description = "OCPUs for the jump host flexible shape."
  type        = number
  default     = 1
}

variable "jump_memory_in_gbs" {
  description = "Memory (GB) for the jump host flexible shape."
  type        = number
  default     = 4
}

# ---------------------------------------------------------------------------
# File Storage
# ---------------------------------------------------------------------------

variable "enable_fss" {
  description = "Create File Storage FS + mount target + export. Required for full lab design."
  type        = bool
  default     = true
}

variable "fss_display_name" {
  description = "File system display name override."
  type        = string
  default     = ""
}

variable "mount_target_display_name" {
  description = "Mount target display name override."
  type        = string
  default     = ""
}

variable "fss_export_path" {
  description = "NFS export path on the file system."
  type        = string
  default     = "/export"
}

variable "fss_export_source_cidr" {
  description = "Client CIDR allowed on the FSS export. Empty uses vcn_cidr."
  type        = string
  default     = ""
}

variable "fss_export_access" {
  description = "Export access level (READ_WRITE or READ_ONLY)."
  type        = string
  default     = "READ_WRITE"
}

variable "mount_target_hostname_label" {
  description = "Optional hostname label for the mount target."
  type        = string
  default     = "w2mt"
}

# ---------------------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------------------

variable "lb_display_name" {
  description = "Load balancer display name override."
  type        = string
  default     = ""
}

variable "lb_shape" {
  description = "LB shape. Use flexible for Flexible Application Load Balancer."
  type        = string
  default     = "flexible"
}

variable "lb_min_bandwidth_mbps" {
  description = "Minimum bandwidth (Mbps) for flexible LB shape."
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Maximum bandwidth (Mbps) for flexible LB shape."
  type        = number
  default     = 10
}

variable "lb_is_private" {
  description = "When true, create a private LB (lab uses public = false)."
  type        = bool
  default     = false
}

variable "lb_backend_set_name" {
  description = "Backend set name on the load balancer."
  type        = string
  default     = "w2-http-bs"
}

variable "lb_backend_set_policy" {
  description = "LB backend set policy (e.g. ROUND_ROBIN)."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "lb_listener_name" {
  description = "HTTP listener name."
  type        = string
  default     = "http"
}

variable "lb_health_check_path" {
  description = "HTTP health check URL path."
  type        = string
  default     = "/"
}

variable "lb_health_check_interval_ms" {
  description = "Health check interval in milliseconds."
  type        = number
  default     = 10000
}

variable "lb_health_check_timeout_ms" {
  description = "Health check timeout in milliseconds."
  type        = number
  default     = 3000
}

variable "lb_health_check_retries" {
  description = "Health check retry count."
  type        = number
  default     = 3
}

variable "lb_health_check_return_code" {
  description = "Expected HTTP return code for healthy backend."
  type        = number
  default     = 200
}

variable "lb_backend_weight" {
  description = "Weight of the app backend."
  type        = number
  default     = 1
}
