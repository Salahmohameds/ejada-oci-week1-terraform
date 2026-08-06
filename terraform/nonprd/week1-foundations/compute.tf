# Linux VM in the public subnet; optional RESERVED public IP attach.

module "instance" {
  source = "../../modules/oracle-instance"

  compartment_id      = var.compartment_ocid
  display_name        = local.instance_display_name
  availability_domain = local.availability_domain
  subnet_id           = module.public_subnet.id
  shape               = var.instance_shape
  ssh_public_keys     = var.ssh_public_key
  # Reserved IP path requires assign_public_ip=false; ephemeral + reserved
  # cannot share the same VNIC private IP.
  assign_public_ip = var.use_reserved_public_ip ? false : var.instance_assign_public_ip
  hostname_label   = "linuxvm"
  freeform_tags    = local.freeform_tags

  shape_config = {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  # Latest Oracle Linux 9 image for this shape (picked inside the module).
  image_operating_system         = "Oracle Linux"
  image_operating_system_version = "9"
}

# Standalone RESERVED public IP → attach to primary private IP on the VNIC.
module "reserved_public_ip" {
  count  = var.use_reserved_public_ip ? 1 : 0
  source = "../../modules/oracle-public-ip"

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-reserved-pip"
  lifetime       = "RESERVED"
  vnic_id        = module.instance.primary_vnic_id
  freeform_tags  = local.freeform_tags
}
