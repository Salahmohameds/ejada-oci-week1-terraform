# OCI Bastion for private app access (PDF secure-access path; jump optional).

resource "oci_bastion_bastion" "this" {
  count = var.enable_bastion ? 1 : 0

  compartment_id               = var.compartment_ocid
  name                         = local.bastion_name
  bastion_type                 = var.bastion_type
  target_subnet_id             = oci_core_subnet.private.id
  client_cidr_block_allow_list = local.bastion_client_cidrs
  max_session_ttl_in_seconds   = var.bastion_max_session_ttl_in_seconds
  freeform_tags                = local.freeform_tags
}
