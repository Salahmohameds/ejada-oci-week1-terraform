# Flexible Application Load Balancer unit: LB + backend set + backend + listener.

resource "oci_load_balancer_load_balancer" "this" {
  compartment_id             = var.compartment_ocid
  display_name               = var.lb_display_name
  shape                      = var.lb_shape
  subnet_ids                 = [var.public_subnet_id]
  is_private                 = var.lb_is_private
  network_security_group_ids = var.nsg_ids
  freeform_tags              = var.freeform_tags

  shape_details {
    minimum_bandwidth_in_mbps = var.lb_min_bandwidth_mbps
    maximum_bandwidth_in_mbps = var.lb_max_bandwidth_mbps
  }
}

resource "oci_load_balancer_backend_set" "http" {
  name             = var.lb_backend_set_name
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  policy           = var.lb_backend_set_policy

  health_checker {
    protocol          = "HTTP"
    port              = var.app_port
    url_path          = var.lb_health_check_path
    interval_ms       = var.lb_health_check_interval_ms
    timeout_in_millis = var.lb_health_check_timeout_ms
    retries           = var.lb_health_check_retries
    return_code       = var.lb_health_check_return_code
  }
}

resource "oci_load_balancer_backend" "app" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.http.name
  ip_address       = var.backend_ip_address
  port             = var.app_port
  backup           = false
  drain            = false
  offline          = false
  weight           = var.lb_backend_weight
}

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = var.lb_listener_name
  default_backend_set_name = oci_load_balancer_backend_set.http.name
  port                     = var.app_port
  protocol                 = "HTTP"
}
