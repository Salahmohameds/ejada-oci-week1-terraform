# Module: compute

Creates the lab's compute instances (private app VM and, optionally, a public jump
host) as a **single cohesive building block**. The module takes a map of instance
configs and uses `for_each` on one `oci_core_instance` resource to create every
instance — callers add or remove VMs by adding/removing entries in the map passed
to `instances`, not by calling this module more than once.

## Files

| File | What it declares |
|------|-------------------|
| `main.tf` | `oci_core_instance.this` (one resource, `for_each = var.instances` — one instance per map entry: shape, shape_config, VNIC/subnet/NSG placement, boot volume, SSH key + optional cloud-init user_data). Local `rendered_user_data` base64-encodes the cloud-init template (`cloud-init/app.yaml.tftpl`) per instance key when that instance's `cloud_init` object is set (null skips cloud-init, e.g. for a plain jump host). |
| `variables.tf` | `compartment_ocid`, `availability_domain`, `image_id`, `freeform_tags` (shared by all instances), and `instances` — the `map(object({...}))` that drives `for_each` (per-instance shape/OCPU/memory/boot volume, subnet + assign_public_ip, hostname_label, nsg_ids, ssh_public_key, optional `cloud_init`). |
| `outputs.tf` | Three maps keyed by the same instance key used in `instances` (see below). |
| `cloud-init/app.yaml.tftpl` | Cloud-init template: mounts the FSS export (retrying until the mount target is ready), writes `index_html_body` to the mount, and starts a systemd unit serving HTTP on `app_port`. Used only for instances whose `cloud_init` object is non-null. |

## Inputs (summary)

- `compartment_ocid`, `availability_domain`, `image_id` — shared across all instances.
- `freeform_tags` — shared tags applied to every instance.
- `instances` — map, one entry per VM (root currently passes `app` always, and `jump` only when `var.enable_jump = true`). Each entry supplies its own `display_name`, `shape`, `ocpus`, `memory_in_gbs`, `boot_volume_size_in_gbs`, `subnet_id`, `assign_public_ip`, `hostname_label`, `nsg_ids`, `ssh_public_key`, and optional `cloud_init` block.

## Outputs — what to look for after apply

| Output | What it is | What to check |
|--------|------------|----------------|
| `instance_ids` | Map `{ "app" = "<ocid>", "jump" = "<ocid>" }` (jump key absent when not created) | Used for Bastion session target and general reference. |
| `instance_private_ips` | Map of instance key → private IP | `instance_private_ips["app"]` feeds the LB backend (`module.lb`) — confirm it's a valid private IP in the private subnet CIDR. |
| `instance_public_ips` | Map of instance key → public IP (only populated for instances with `assign_public_ip = true`) | `instance_public_ips["jump"]` is the SSH target when `enable_jump = true`; expect `null`/absent otherwise. |

Root consumes these as `module.compute.instance_ids["app"]`, `module.compute.instance_private_ips["app"]`,
`try(module.compute.instance_ids["jump"], null)`, etc.
