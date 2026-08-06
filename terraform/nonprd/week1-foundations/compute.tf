module "instance" {
  source = "../../modules/oracle-instance"

  compartment_id      = var.compartment_ocid
  display_name        = local.instance_display_name
  availability_domain = local.availability_domain
  subnet_id           = module.public_subnet.id
  shape               = var.instance_shape
  ssh_public_keys     = var.ssh_public_key
  # Ephemeral public IP only when reserved path is off; reserved IPs cannot
  # coexist on the same VNIC private IP with an ephemeral assignment.
  assign_public_ip = var.use_reserved_public_ip ? false : var.instance_assign_public_ip
  hostname_label   = "linuxvm"
  freeform_tags    = local.freeform_tags

  shape_config = {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  # Oracle Linux 9 resolved via data.oci_core_images inside the module.
  image_operating_system         = "Oracle Linux"
  image_operating_system_version = "9"
}

# Reserved (static) public IP — Azure Static Public IP / Standard PIP equivalent.
# Pattern: create instance with assign_public_ip=false, then attach RESERVED IP
# to the primary private IP on the VNIC.
module "reserved_public_ip" {
  count  = var.use_reserved_public_ip ? 1 : 0
  source = "../../modules/oracle-public-ip"

  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-reserved-pip"
  lifetime       = "RESERVED"
  vnic_id        = module.instance.primary_vnic_id
  freeform_tags  = local.freeform_tags
}
