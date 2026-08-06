# Resolve primary private IP from the VNIC when private_ip_id is not supplied.
# Reserved public IPs attach to a private IP object, not the instance OCID directly.
data "oci_core_private_ips" "from_vnic" {
  count = var.private_ip_id == null ? 1 : 0

  vnic_id = var.vnic_id
}

locals {
  primary_private_ip = var.private_ip_id == null ? try(
    [
      for pip in data.oci_core_private_ips.from_vnic[0].private_ips : pip
      if try(pip.is_primary, true)
    ][0],
    data.oci_core_private_ips.from_vnic[0].private_ips[0]
  ) : null

  private_ip_id = coalesce(
    var.private_ip_id,
    try(local.primary_private_ip.id, null)
  )
}

resource "oci_core_public_ip" "this" {
  compartment_id = var.compartment_id
  lifetime       = var.lifetime
  display_name   = var.display_name
  private_ip_id  = local.private_ip_id

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
