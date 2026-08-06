locals {
  name_prefix = var.name_prefix

  freeform_tags = {
    Project   = var.project_tag
    Lab       = var.lab_tag
    ManagedBy = "Terraform"
  }

  # Empty display_name override → name_prefix-linux-vm.
  instance_display_name = coalesce(
    var.instance_display_name != "" ? var.instance_display_name : null,
    "${local.name_prefix}-linux-vm"
  )

  # AD picked by index so compute + block volume land in the same domain.
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name
}
