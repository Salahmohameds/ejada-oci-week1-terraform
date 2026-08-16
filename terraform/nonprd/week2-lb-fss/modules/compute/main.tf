# Compute building block: N instances (app, jump, ...) from ONE resource via for_each.
# Callers pass var.instances as a map; add/remove map entries to add/remove VMs.

locals {
  # Render cloud-init once per instance that requests it; null for instances without cloud_init.
  rendered_user_data = {
    for key, inst in var.instances : key => (
      inst.cloud_init == null ? null : base64encode(templatefile("${path.module}/cloud-init/app.yaml.tftpl", {
        mount_target_ip  = inst.cloud_init.mount_target_ip
        fss_export_path  = inst.cloud_init.fss_export_path
        app_mount_path   = inst.cloud_init.app_mount_path
        app_port         = tostring(inst.cloud_init.app_port)
        index_html_body  = inst.cloud_init.index_html_body
        enable_fss_mount = inst.cloud_init.enable_fss_mount ? "true" : "false"
      }))
    )
  }
}

resource "oci_core_instance" "this" {
  for_each = var.instances

  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = each.value.display_name
  shape               = each.value.shape
  freeform_tags       = var.freeform_tags

  shape_config {
    ocpus         = each.value.ocpus
    memory_in_gbs = each.value.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = each.value.subnet_id
    assign_public_ip = each.value.assign_public_ip
    hostname_label   = each.value.hostname_label
    display_name     = "${each.value.display_name}-vnic"
    nsg_ids          = each.value.nsg_ids
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
  }

  metadata = merge(
    { ssh_authorized_keys = each.value.ssh_public_key },
    local.rendered_user_data[each.key] != null ? { user_data = local.rendered_user_data[each.key] } : {}
  )

  preserve_boot_volume = false
}
