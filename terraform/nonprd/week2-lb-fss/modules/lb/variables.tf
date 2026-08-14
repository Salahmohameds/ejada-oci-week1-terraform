variable "compartment_ocid" {
  description = "Compartment OCID for the load balancer."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet OCID for the LB."
  type        = string
}

variable "nsg_ids" {
  description = "NSG OCIDs attached to the load balancer."
  type        = list(string)
  default     = []
}

variable "freeform_tags" {
  description = "Freeform tags for LB resources."
  type        = map(string)
  default     = {}
}

variable "lb_display_name" {
  description = "Load balancer display name."
  type        = string
}

variable "lb_shape" {
  description = "LB shape (flexible)."
  type        = string
}

variable "lb_min_bandwidth_mbps" {
  description = "Minimum bandwidth (Mbps) for flexible LB."
  type        = number
}

variable "lb_max_bandwidth_mbps" {
  description = "Maximum bandwidth (Mbps) for flexible LB."
  type        = number
}

variable "lb_is_private" {
  description = "When true, create a private LB."
  type        = bool
}

variable "lb_backend_set_name" {
  description = "Backend set name."
  type        = string
}

variable "lb_backend_set_policy" {
  description = "Backend set policy."
  type        = string
}

variable "lb_listener_name" {
  description = "HTTP listener name."
  type        = string
}

variable "app_port" {
  description = "Backend and listener port."
  type        = number
}

variable "backend_ip_address" {
  description = "Private IP of the app backend."
  type        = string
}

variable "lb_health_check_path" {
  description = "HTTP health check URL path."
  type        = string
}

variable "lb_health_check_interval_ms" {
  description = "Health check interval in milliseconds."
  type        = number
}

variable "lb_health_check_timeout_ms" {
  description = "Health check timeout in milliseconds."
  type        = number
}

variable "lb_health_check_retries" {
  description = "Health check retry count."
  type        = number
}

variable "lb_health_check_return_code" {
  description = "Expected HTTP return code."
  type        = number
}

variable "lb_backend_weight" {
  description = "Weight of the app backend."
  type        = number
}
