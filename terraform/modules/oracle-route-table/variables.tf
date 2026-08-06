variable "compartment_id" {
  description = "OCID of the compartment where the route table will be created."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN that owns this route table."
  type        = string
}

variable "display_name" {
  description = "Display name for the route table."
  type        = string
}

variable "route_rules" {
  description = <<-EOT
    Route rules for the table.
    Example public default route to IGW:
      [{ destination = "0.0.0.0/0", destination_type = "CIDR_BLOCK", network_entity_id = igw_id }]
    Private RT often passes an empty list (no internet egress).
  EOT
  type = list(object({
    destination       = string
    destination_type  = optional(string, "CIDR_BLOCK")
    network_entity_id = string
    description       = optional(string)
  }))
  default = []
}

variable "freeform_tags" {
  description = "Freeform tags to apply to the route table."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to the route table."
  type        = map(string)
  default     = {}
}
