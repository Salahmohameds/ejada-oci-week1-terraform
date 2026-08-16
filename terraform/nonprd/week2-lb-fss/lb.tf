# Flexible ALB: load balancer + backend set + backend + listener.

module "lb" {
  source = "./modules/lb"

  compartment_ocid            = var.compartment_ocid
  public_subnet_id            = module.network.public_subnet_id
  nsg_ids                     = module.network.nsg_lb_ids
  freeform_tags               = local.freeform_tags
  lb_display_name             = local.lb_display_name
  lb_shape                    = var.lb_shape
  lb_min_bandwidth_mbps       = var.lb_min_bandwidth_mbps
  lb_max_bandwidth_mbps       = var.lb_max_bandwidth_mbps
  lb_is_private               = var.lb_is_private
  lb_backend_set_name         = var.lb_backend_set_name
  lb_backend_set_policy       = var.lb_backend_set_policy
  lb_listener_name            = var.lb_listener_name
  app_port                    = var.app_port
  backend_ip_address          = module.compute.instance_private_ips["app"]
  lb_health_check_path        = var.lb_health_check_path
  lb_health_check_interval_ms = var.lb_health_check_interval_ms
  lb_health_check_timeout_ms  = var.lb_health_check_timeout_ms
  lb_health_check_retries     = var.lb_health_check_retries
  lb_health_check_return_code = var.lb_health_check_return_code
  lb_backend_weight           = var.lb_backend_weight
}
