variable "compartment_ocid" {
  description = "Compartment OCID for network resources."
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags applied to network resources."
  type        = map(string)
  default     = {}
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet (ALB, optional jump)."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet (app VM, FSS mount target)."
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN."
  type        = string
}

variable "public_subnet_dns_label" {
  description = "DNS label for the public subnet."
  type        = string
}

variable "private_subnet_dns_label" {
  description = "DNS label for the private subnet."
  type        = string
}

variable "vcn_display_name" {
  description = "VCN display name."
  type        = string
}

variable "igw_display_name" {
  description = "Internet gateway display name."
  type        = string
}

variable "nat_display_name" {
  description = "NAT gateway display name."
  type        = string
}

variable "sgw_display_name" {
  description = "Service gateway display name."
  type        = string
}

variable "public_rt_display_name" {
  description = "Public route table display name."
  type        = string
}

variable "private_rt_display_name" {
  description = "Private route table display name."
  type        = string
}

variable "public_sl_display_name" {
  description = "Public security list display name."
  type        = string
}

variable "private_sl_display_name" {
  description = "Private security list display name."
  type        = string
}

variable "public_subnet_display_name" {
  description = "Public subnet display name."
  type        = string
}

variable "private_subnet_display_name" {
  description = "Private subnet display name."
  type        = string
}

variable "nsg_lb_display_name" {
  description = "LB NSG display name."
  type        = string
}

variable "nsg_app_display_name" {
  description = "App NSG display name."
  type        = string
}

variable "nsg_mt_display_name" {
  description = "Mount target NSG display name."
  type        = string
}

variable "enable_service_gateway" {
  description = "Create Service Gateway + private RT route for All region Services in OSN."
  type        = bool
}

variable "enable_nsgs" {
  description = "Create NSGs for LB, app, and mount target."
  type        = bool
}

variable "enable_fss" {
  description = "When true with enable_nsgs, create the mount-target NSG."
  type        = bool
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH on the public security list."
  type        = string
}

variable "app_port" {
  description = "HTTP port for ALB and app."
  type        = number
}

variable "enable_https_ingress" {
  description = "Allow TCP/443 from the internet on public SL and LB NSG."
  type        = bool
}
