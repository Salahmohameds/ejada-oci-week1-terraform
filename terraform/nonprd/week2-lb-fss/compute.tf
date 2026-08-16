# Compute: ONE module call driving N instances (app, optional jump) via for_each.
# See local.compute_instances (locals.tf) for the map fed into the module.

module "compute" {
  source = "./modules/compute"

  compartment_ocid    = var.compartment_ocid
  availability_domain = local.availability_domain
  image_id            = local.image_id
  freeform_tags       = local.freeform_tags
  instances           = local.compute_instances

  # cloud-init needs export ready when FSS is enabled.
  depends_on = [module.storage]
}
