# Module: storage

File Storage building block: file system + mount target + NFS export, created (or
skipped) together as one unit behind `enable_fss`. Grouped into one module because
none of the three resources is independently useful — an export needs a file
system and a mount target's export set; a mount target on its own serves nothing.

## Files

| File | What it declares |
|------|-------------------|
| `main.tf` | `oci_file_storage_file_system.this`, `oci_file_storage_mount_target.this`, `oci_file_storage_export.this` (export options: source CIDR, access level, no identity squash), and `data.oci_core_private_ip.mount_target` (reads the mount target's private IP for cloud-init). All four are `count = var.enable_fss ? 1 : 0` — the whole group is created or skipped together. |
| `variables.tf` | `compartment_ocid`, `availability_domain`, `private_subnet_id`, `nsg_ids`, `freeform_tags`, `enable_fss`, display-name/hostname-label overrides, `fss_export_path`, `fss_export_source_cidr`, `fss_export_access`. |
| `outputs.tf` | IDs and the mount target IP needed by `module.compute`'s cloud-init (see below). |

## Outputs — what to look for after apply

| Output | What it is | What to check |
|--------|------------|----------------|
| `file_system_id` | OCID of the file system, `null` when `enable_fss = false` | Confirms the FS exists before checking the export. |
| `mount_target_id` | OCID of the mount target, `null` when disabled | Cross-reference in console → File Storage → Mount Targets. |
| `mount_target_ip` | Private IP of the mount target, `null` when disabled | Fed into `module.compute`'s cloud-init as `mount_target_ip` — the app VM mounts `<this-ip>:<fss_export_path>`. Should be inside `private_subnet_cidr`. |
| `export_id` | OCID of the NFS export, `null` when disabled | Confirms the export attached to the right file system/mount target. |
| `fss_export_path` | Echo of `var.fss_export_path` when enabled, else `null` | Should match the path cloud-init mounts on the app VM (`/export` by default). |
