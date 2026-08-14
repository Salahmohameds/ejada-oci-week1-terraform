output "lb_id" {
  description = "OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.this.id
}

output "lb_public_ip" {
  description = "Public IP of the load balancer."
  value       = try(oci_load_balancer_load_balancer.this.ip_address_details[0].ip_address, null)
}
