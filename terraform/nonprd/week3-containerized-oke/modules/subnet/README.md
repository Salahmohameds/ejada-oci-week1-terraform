# Module: subnet

Subnet related-group: one subnet plus its own route table, security list, and
optional VCN flow-log stack (capture filter + log group + log). The module is
generic — routing and security rules are rendered from input lists via
`dynamic` blocks, so the same module code produces the public `lb` subnet and
the private `workers`/`pods` subnets without any per-type branching.

Called **once** from the root (`subnets.tf`) with `for_each = local.subnets`
(keys `lb`, `workers`, `pods`) — three subnets come from one module call, not
three separate calls to three copies of the same module.

## Files

| File | Declares |
|---|---|
| `main.tf` | `oci_core_security_list.this` (ingress/egress rendered with `dynamic` blocks, including nested `tcp_options`/`udp_options`/`icmp_options`), `oci_core_route_table.this` (default route + optional `extra_route_rules` via `dynamic` blocks), `oci_core_subnet.this`, `oci_logging_log_group.this` (count, only when this call should create its own log group), `oci_core_capture_filter.flow` (count, only when flow logs are enabled and this call creates the filter), `oci_logging_log.flow` (count, the SERVICE flow log itself). |
| `variables.tf` | Every input below. |
| `outputs.tf` | Every output below. |
| `versions.tf` | Declares the `oci` provider requirement; inherits provider configuration from the root. |

## Inputs

| Variable | Description |
|---|---|
| `compartment_ocid` | Compartment OCID for the subnet, route table, security list, and optional logs. |
| `vcn_id` | VCN OCID that owns this subnet, route table, and security list (from `module.network.vcn_id`). |
| `display_name` | Subnet display name; route table and security list names derive from it unless overridden. |
| `cidr_block` | IPv4 CIDR for the subnet. |
| `dns_label` | DNS label for the subnet (letters/digits, max 15). |
| `prohibit_public_ip_on_vnic` | `true` = private subnet, `false` = public. |
| `route_table_display_name` | Route table display name override. Empty uses `<display_name>-rt`. |
| `security_list_display_name` | Security list display name override. Empty uses `<display_name>-sl`. |
| `default_route_gateway_id` | IGW or NAT OCID for the `0.0.0.0/0` route. `null` skips the default route. |
| `default_route_destination` | Destination CIDR for the default route rule. |
| `default_route_description` | Description on the default route rule. |
| `extra_route_rules` | Optional extra route-table rules (e.g. Service Gateway). Empty list = none. |
| `ingress_security_rules` | Ingress rules rendered with `dynamic` blocks (protocol `1`=ICMP, `6`=TCP, `17`=UDP, `all`). |
| `egress_security_rules` | Egress rules rendered with `dynamic` blocks. |
| `freeform_tags` | Freeform tags applied to subnet-related resources. |
| `defined_tags` | Defined tags applied to subnet-related resources. |
| `enable_logs` | Create a SERVICE flow log (and capture filter) for this subnet. |
| `create_log_group` | Create a log group inside this call instead of using a shared one. Must be a known bool — never derived from `log_group_id`, which is unknown until apply. |
| `log_group_id` | Existing log group OCID to attach the flow log to when `create_log_group` is `false`. |
| `log_group_display_name` | Log group display name when this call creates one. Empty uses `<display_name>-logs`. |
| `log_display_name` | Flow log display name. Empty uses `<display_name>-flow-log`. |
| `log_retention_duration` | Log retention in days (30/60/90/120/150/180). |
| `log_category` | Logging source category for VCN flow logs. |
| `log_service` | Logging service name for VCN flow logs. |
| `create_capture_filter` | Create an `oci_core_capture_filter` and attach it to the flow log. |
| `capture_filter_display_name` | Capture filter display name. Empty uses `<display_name>-flow-filter`. |
| `flow_log_sampling_rate` | Capture-filter sampling rate (1, 10, 50, or 100). |
| `capture_filter_id` | Existing capture filter OCID to reuse when `create_capture_filter` is `false`. |

## Outputs

| Output | Used for |
|---|---|
| `subnet_id` | Consumed by `module.oke` (`endpoint_subnet_id`, `worker_subnet_id`, `pod_subnet_ids`, `service_lb_subnet_id`) via `module.subnet["lb"|"workers"|"pods"].subnet_id`. Expect a valid subnet OCID per key. |
| `subnet_cidr` | Convenience output mirroring the subnet's CIDR block, useful for cross-checking NSG/SL source CIDRs. |
| `route_table_id` | OCID of the subnet's own route table. |
| `security_list_id` | OCID of the subnet's own security list. |
| `log_group_id` | Log group OCID actually in use by this subnet (either the one it created or the shared one passed in). `null` when `enable_logs` is `false`. |
| `log_id` | Flow log OCID when `enable_logs` is `true`, otherwise `null`. |
| `capture_filter_id` | Capture filter OCID in use when flow logs are enabled, otherwise `null`. |
| `prohibit_public_ip_on_vnic` | Echoes the subnet's public/private setting for quick verification against `var.subnets`. |

## What to expect after apply

Three subnet instances (`module.subnet["lb"]`, `module.subnet["workers"]`,
`module.subnet["pods"]`) from this single `for_each` call, each with its own
route table and security list. Only the `lb` key additionally has a flow log,
capture filter, and (via the shared log group from `module.network`) an entry
in the shared VCN log group.
