# Week 2 Lab 2 — LB + FSS (Terraform)

**Status:** Lab complete then **destroyed** (2026-08-09). Re-apply from this code for a fresh stack. Full student write-up: `labs/week2-lab2-lb-fss/WEEK2-LAB2-TERRAFORM-DOCUMENTATION.md`.

## Architecture

| Layer | Resources |
|-------|-----------|
| Network | VCN `10.1.0.0/16`, public/private subnets, IGW, NAT, **SGW**, RTs, SLs + **NSGs** |
| Compute | Private app (no public IP); cloud-init mounts FSS and starts HTTP :80 |
| Storage | File system + mount target (private, NSG) + export `/export` |
| LB | Flexible Application LB (NSG); backend private app :80; health `/` |
| Access | **OCI Bastion** (`enable_bastion`); optional jump (`enable_jump` default false) |

Root is multi-file and calls **cohesive modules** for related groups (not one-resource wrappers). Tunable values: variables / gitignored `terraform.tfvars`.

## Layout

```text
week2-lb-fss/
  versions.tf  providers.tf  variables.tf  locals.tf  data.tf
  network.tf   compute.tf    storage.tf    lb.tf       bastion.tf
  outputs.tf   terraform.tfvars.example    README.md
  modules/
    network/   # VCN + IGW + NAT + SGW + RTs + SLs + NSGs + subnets
    compute/   # private app + optional jump + cloud-init
    storage/   # FSS + mount target + export
    lb/        # ALB + backend set + backend + listener
```

Bastion stays as a single root `oci_*` resource (not a thin one-resource module).

## Prerequisites

1. OCI CLI profile with compartment rights (Bastion create needs `manage bastion-family` or equivalent)
2. Terraform `>= 1.5`
3. SSH public key for instance metadata
4. Copy example tfvars and fill values

```bash
cd terraform/nonprd/week2-lb-fss
cp terraform.tfvars.example terraform.tfvars
# edit: compartment_ocid, ssh_public_key, allowed_ssh_cidr
```

## Remote state (planned)

`backend.tf` configures the Terraform `s3` backend against OCI Object
Storage's S3-compatible API, storing state at
`w-terraform-state-intern18/week2-lb-fss/terraform.tfstate` instead of a
local `terraform.tfstate`. This is not active until the one-time setup below
is done:

1. Apply `../bootstrap-state/` once to create the bucket (see its README).
2. Terraform backend blocks only take literal values, so replace
   `<namespace>` in `backend.tf` with the real namespace from the bootstrap
   stack's `namespace` output (or use `backend.hcl` — copy
   `backend.hcl.example`, fill it in, gitignored — with
   `terraform init -backend-config=backend.hcl`).
3. Export the S3-compatible credentials (an OCI Customer Secret Key, not the
   `oci` provider's config profile) before `terraform init`:

   ```powershell
   $env:AWS_ACCESS_KEY_ID     = "<customer-secret-key access key>"
   $env:AWS_SECRET_ACCESS_KEY = "<customer-secret-key secret key>"
   ```

4. `terraform init -reconfigure`.

Never commit `backend.hcl` or the secret key value — only `backend.tf` (no
secrets, literal bucket/region/endpoint) and `backend.hcl.example` are
tracked.

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Wait **3–5 minutes** for cloud-init, then:

```bash
curl "http://$(terraform output -raw lb_public_ip)/"
```

Useful outputs: `lb_public_ip`, `lb_url`, `nsg_*_id`, `service_gateway_id`, `bastion_id`, `bastion_session_create_hint`.

## Secure access model

| Path | Role |
|------|------|
| Internet → ALB :80 → private app | Public app traffic |
| Private subnet → NAT | Package updates / general egress |
| Private subnet → SGW | Oracle Services Network without Internet hairpin |
| Workstations → **Bastion** → private :22 | Admin SSH (PDF model); client CIDR = `allowed_ssh_cidr` |
| `enable_jump` | Optional public jump VM only (not default) |

Session create (when bastion exists):

```bash
oci bastion session create-managed-ssh \
  --bastion-id "$(terraform output -raw bastion_id)" \
  --target-resource-id "$(terraform output -raw app_instance_id)" \
  --target-os-username opc \
  --target-private-key-file <private-key> \
  --ssh-public-key-file <public-key> \
  --session-ttl 1800 --wait-for-state SUCCEEDED
```

## Variables (selected)

| Variable | Purpose |
|----------|---------|
| `compartment_ocid` | Target compartment |
| `allowed_ssh_cidr` | Jump SL + Bastion client allow-list |
| `enable_nsgs` / `enable_service_gateway` / `enable_bastion` | Feature toggles (default true) |
| `bastion_type` | `PUBLIC` (lab) or `STANDARD` |
| `enable_jump` | Public jump host (default false) |
| `enable_fss` / `app_port` / LB bandwidth vars | Lab shape knobs |

Full list: `variables.tf`.

## Destroy

```bash
terraform destroy
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| LB 502 | Wait cloud-init; SL + NSG allow public→private :app_port |
| NFS fail | MT IP/export, MT NSG + private SL NFS ports, export CIDR |
| Bastion create 404 | Need IAM `manage bastion-family` (and related); stack NSG/SGW still valid |
| SSH without Bastion | `enable_jump = true` or fix Bastion IAM |

## Lab reference

- [`labs/week2-lab2-lb-fss/`](../../../labs/week2-lab2-lb-fss/)
- [`docs/TERRAFORM.md`](../../../labs/week2-lab2-lb-fss/docs/TERRAFORM.md) — PDF appendix
