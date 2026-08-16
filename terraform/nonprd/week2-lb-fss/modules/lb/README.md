# Module: lb

Flexible Application Load Balancer building block: the load balancer, its HTTP
backend set, the single app backend, and the HTTP listener. Grouped into one
module because a backend set with no listener, or a listener with no backend set,
is not a working load balancer — these four resources are one logical unit.

## Files

| File | What it declares |
|------|-------------------|
| `main.tf` | `oci_load_balancer_load_balancer.this` (shape + bandwidth via `shape_details`, subnet, NSGs, `is_private`); `oci_load_balancer_backend_set.http` (policy + HTTP health checker); `oci_load_balancer_backend.app` (the app instance's private IP as the single backend); `oci_load_balancer_listener.http` (HTTP listener bound to the backend set). |
| `variables.tf` | `compartment_ocid`, `public_subnet_id`, `nsg_ids`, `freeform_tags`, LB display name/shape/bandwidth/`lb_is_private`, backend set name/policy, listener name, `app_port`, `backend_ip_address` (from `module.compute.instance_private_ips["app"]`), and health-check tuning (`lb_health_check_path`, `_interval_ms`, `_timeout_ms`, `_retries`, `_return_code`), `lb_backend_weight`. |
| `outputs.tf` | LB id and public IP (see below). |

## Outputs — what to look for after apply

| Output | What it is | What to check |
|--------|------------|----------------|
| `lb_id` | OCID of the load balancer | Reference for console lookup / troubleshooting. |
| `lb_public_ip` | Public IP address of the LB (`null` if the LB has no public IP, e.g. `lb_is_private = true`) | Root builds `lb_url` from this; `curl http://<lb_public_ip>/` should return the app's `index_html_body` once cloud-init finishes and the backend is healthy. |
