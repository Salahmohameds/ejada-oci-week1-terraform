# Ejada Terraform monorepo

Terraform for the **Ejada Cloud Build** OCI track. Reusable modules plus thin **environment root stacks** that wire them together.

```
terraform/
  modules/                 # reusable building blocks (no env-specific OCIDs)
  nonprd/                  # non-production environment stacks
    week1-foundations/     # Week 1 Lab 1 landing zone
    week2-lb-fss/          # Week 2 Lab 2 — ALB + private app + FSS (cohesive nested modules)
    week3-containerized-oke/  # Week 3 — subnet + OKE modules, VCN-native CNI (do not apply yet)
  README.md                # this file
```

## Design rules

| Rule | Why |
|------|-----|
| Modules = reusable OCI primitives | Share VCN/subnet/instance patterns across labs |
| Environment roots own `provider` | Auth and region never buried inside modules |
| `*.tfvars` gitignored (except `*.example`) | No secrets / real OCIDs in git |
| Freeform tags on resources | `Project`, `Lab`, `ManagedBy` for cleanup and audits |
| `name_prefix` for display names | Consistent `w1-*` naming aligns with console lab |

## Current stacks

| Path | Purpose |
|------|---------|
| [`nonprd/week1-foundations`](./nonprd/week1-foundations/) | Week 1 Lab 1: VCN, IGW, public/private subnets, Linux VM, block volume; **FSS optional (default off)** |
| [`nonprd/week2-lb-fss`](./nonprd/week2-lb-fss/) | Week 2 Lab 2: public ALB + private app + FSS (nested `network` / `compute` / `storage` / `lb` modules) |
| [`nonprd/week3-containerized-oke`](./nonprd/week3-containerized-oke/) | Week 3: reusable `subnet` + `oke` modules (VCN-native CNI, managed node pool); **code only — do not apply until quota is confirmed** |
| [`nonprd/bootstrap-state`](./nonprd/bootstrap-state/) | One-time bucket for remote Terraform state (see **Remote state** below); stays on local state itself |

## Modules

| Module | Resources |
|--------|-----------|
| `oracle-vcn` | VCN |
| `oracle-internet-gateway` | Internet Gateway (no gateway RT attachment) |
| `oracle-route-table` | Route table + rules |
| `oracle-security-list` | Security list ingress/egress |
| `oracle-subnet` | Subnet |
| `oracle-instance` | Compute + Oracle Linux 9 image data source |
| `oracle-public-ip` | Reserved (or ephemeral) public IP assignable to a private IP / VNIC |
| `oracle-block-volume` | Block volume + optional paravirtualized attach |
| `oracle-file-system` | File system + mount target + export |

## Quick start

```bash
cd terraform/nonprd/week1-foundations
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars (compartment, SSH key, allowed_ssh_cidr)

terraform init
terraform plan
terraform apply
```

See the stack README for architecture, IGW footgun notes, validation, and destroy steps.

## Authentication

**Preferred (interns):** OCI config file profile.

```hcl
provider "oci" {
  region              = var.region
  config_file_profile = "DEFAULT"
}
```

**Alternative:** `tenancy_ocid` / `user_ocid` / `fingerprint` / `private_key_path` via local tfvars only — never commit keys.

## Remote state (planned)

`week2-lb-fss` and `week3-containerized-oke` each ship a `backend.tf` that
configures the Terraform `s3` backend against OCI Object Storage's
S3-compatible API, so state lives in one bucket instead of local
`terraform.tfstate` files. This is code-ready but not active yet — it needs
one manual, one-time setup:

1. **Create the bucket:** apply [`nonprd/bootstrap-state`](./nonprd/bootstrap-state/)
   once (`terraform init && terraform plan && terraform apply` in that
   folder). It creates a single bucket (default name
   `w-terraform-state-intern18`, versioning enabled) in the intern-18
   compartment, region `me-jeddah-1`. This bootstrap stack intentionally
   keeps **local** state itself — the bucket can't hold its own state before
   it exists (see its README for the full rationale).
2. **Fill in the namespace:** Terraform `backend` blocks only accept literal
   values (no variables), so take the `namespace` output from the bootstrap
   apply and replace `<namespace>` in each stack's `backend.tf` — or use the
   provided `backend.hcl.example` → local, gitignored `backend.hcl` with
   `terraform init -backend-config=backend.hcl`.
3. **State keys per stack:**
   - `week2-lb-fss/terraform.tfstate`
   - `week3-containerized-oke/terraform.tfstate`
4. **Credentials:** the `s3` backend authenticates with an **OCI Customer
   Secret Key** (S3-compatible access key/secret), separate from the `oci`
   provider's config-file profile. Generate one, once, via OCI Console
   (Identity → Users → your user → Customer Secret Keys) or
   `oci iam customer-secret-key create --user-id <your-user-ocid> --display-name terraform-backend-key`,
   then set it locally as environment variables before `terraform init`:

   ```powershell
   $env:AWS_ACCESS_KEY_ID     = "<customer-secret-key access key>"
   $env:AWS_SECRET_ACCESS_KEY = "<customer-secret-key secret key>"
   ```

   Never commit the secret key value, `terraform.tfvars`, or a real
   `backend.hcl` — only `backend.tf` (literal, non-secret bucket/region/
   endpoint) and `backend.hcl.example` are tracked.
5. **Re-init each stack:** `terraform init -reconfigure` in `week2-lb-fss`
   and `week3-containerized-oke` to switch from local to remote state.

## Secrets & gitignore

This tree (or the repo root) ignores:

- `.terraform/`
- `*.tfstate*`
- `*.tfvars` (not `*.tfvars.example`)
- `*.pem`
- `backend.hcl` (not `backend.hcl.example`)
- `.oci-s3-credentials`, `.env*`

## File Storage quota

`enable_file_storage` defaults to **false**. Mount targets are frequently over quota on shared tenancies. Enable only when mentors free capacity.

## Relation to labs

Manual console walkthrough: `labs/week1-lab1-oci-console/`. This Terraform expresses the same target infrastructure for Lab 2+ IaC practice and rebuilds.
