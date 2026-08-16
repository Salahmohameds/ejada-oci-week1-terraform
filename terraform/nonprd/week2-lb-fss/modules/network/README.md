# Module: network

Cohesive network edge for the lab: VCN, Internet Gateway, NAT Gateway, optional
Service Gateway, route tables, security lists, optional NSGs, and the two subnets
(public/private). Kept as one module because every piece here only makes sense
together (e.g. a route table without its VCN, or an NSG without its VCN, is not a
usable building block on its own).

## Files

| File | What it declares |
|------|-------------------|
| `main.tf` | `data.oci_core_services.all_osn` (OSN service lookup for the Service Gateway route); `oci_core_vcn.this`; `oci_core_internet_gateway.this`; `oci_core_nat_gateway.this`; `oci_core_service_gateway.this` (count-gated by `enable_service_gateway`); `oci_core_route_table.public` / `.private` (private RT adds the SGW route via `dynamic "route_rules"` when enabled); `oci_core_security_list.public` / `.private` (SSH/HTTP/HTTPS/ICMP/NFS rules, several via `dynamic` blocks); `oci_core_subnet.public` / `.private`; NSGs `lb` / `app` / `mt` and their ingress/egress rules (count-gated by `enable_nsgs`, and `enable_fss` for the mount-target NSG) — the mount-target NFS ingress rules use `for_each` over `local.nsg_mt_nfs_rules` (one module already using the for-each-over-a-list pattern the mentor wants, not repeated resource blocks). |
| `variables.tf` | `compartment_ocid`, `freeform_tags`, CIDRs (`vcn_cidr`, `public_subnet_cidr`, `private_subnet_cidr`), DNS labels, display-name overrides for every resource, `enable_service_gateway`, `enable_nsgs`, `enable_fss` (gates the mount-target NSG only), `allowed_ssh_cidr`, `app_port`, `enable_https_ingress`. |
| `outputs.tf` | IDs needed by the other modules/root (see below). |

## Outputs — what to look for after apply

| Output | What it is | What to check |
|--------|------------|----------------|
| `vcn_id` | OCID of the VCN | Sanity check the stack landed in the right compartment/region. |
| `public_subnet_id` / `private_subnet_id` | Subnet OCIDs | Consumed by `module.compute`, `module.storage`, `module.lb`. |
| `service_gateway_id` | SGW OCID, `null` when `enable_service_gateway = false` | Confirms private-subnet egress to OSN doesn't hairpin through the Internet. |
| `nsg_lb_id` / `nsg_app_id` / `nsg_mt_id` | Single NSG OCID per tier, `null` when not created | Use to spot-check NSG rules in the console. |
| `nsg_lb_ids` / `nsg_app_ids` / `nsg_mt_ids` | Same NSGs wrapped as lists (`[]` when disabled) | These are what's actually wired into `network_security_group_ids` on the LB/instance VNICs/mount target — expect one-element lists when NSGs are enabled. |
