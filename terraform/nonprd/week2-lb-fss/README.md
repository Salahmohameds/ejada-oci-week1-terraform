# Week 2 Lab 2 — LB + FSS (Terraform)

Public flexible Application Load Balancer in front of a **private** app instance that mounts **File Storage** and serves a simple HTTP page. Direct `oci_*` resources only (no thin single-resource modules). Configuration lives in variables + local `terraform.tfvars` (gitignored).

## What it deploys

| Layer | Resources |
|-------|-----------|
| Network | VCN (`10.1.0.0/16` example), public/private subnets, IGW, NAT, **SGW**, route tables, security lists |
| Security | **NSGs** for LB, app, and mount target (optional via flags) |
| Compute | Private app (no public IP); cloud-init mounts FSS and starts HTTP on `:80` |
| Storage | File system + mount target (private) + export `/export` |
| LB | Flexible public ALB → backend private app; health check `/` |
| Access | **OCI Bastion** (`enable_bastion`); optional public jump (`enable_jump`, default `false`) |

## Layout

```text
week2-lb-fss/
  versions.tf  providers.tf  variables.tf  locals.tf  data.tf
  network.tf   nsg.tf        bastion.tf    compute.tf
  storage.tf   lb.tf         outputs.tf
  cloud-init/app.yaml.tftpl
  terraform.tfvars.example
  README.md
```

## Prerequisites

1. OCI CLI profile with rights in the target compartment  
   - Bastion create typically needs `manage bastion-family` (or equivalent)
2. Terraform `>= 1.5`
3. SSH public key for instance metadata
4. Copy example tfvars and fill real values

```bash
cd terraform/nonprd/week2-lb-fss
cp terraform.tfvars.example terraform.tfvars
# edit: compartment_ocid, ssh_public_key, allowed_ssh_cidr (YOUR_IP/32)
```

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Wait a few minutes for cloud-init, then:

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
| Workstations → Bastion → private :22 | Admin SSH; client CIDR = `allowed_ssh_cidr` |
| `enable_jump` | Optional public jump VM (not default) |

Example Bastion session create (when bastion exists and IAM allows):

```bash
oci bastion session create-managed-ssh \
  --bastion-id "$(terraform output -raw bastion_id)" \
  --target-resource-id "$(terraform output -raw app_instance_id)" \
  --target-os-username opc \
  --target-private-key-file <private-key> \
  --ssh-public-key-file <public-key> \
  --session-ttl 1800 --wait-for-state SUCCEEDED
```

If Bastion create fails (authorization / 404), fix IAM or set `enable_bastion = false` / `enable_jump = true`. NSG, SGW, ALB, and FSS remain valid.

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
| LB 502 | Wait cloud-init; SL + NSG allow public→private `:app_port` |
| NFS fail | MT IP/export, MT NSG + private SL NFS ports, export CIDR |
| Bastion create 404 / auth | IAM for Bastion; otherwise jump host flag |
| SSH without Bastion | `enable_jump = true` or fix Bastion IAM |
