# Week 3 — Containerized application / OKE (Terraform)

**Student:** Salah Abdelhady  
**Authoritative lab write-up:** [`../../../labs/week3-containerized-oke/WEEK3-LAB3-TERRAFORM-DOCUMENTATION.md`](../../../labs/week3-containerized-oke/WEEK3-LAB3-TERRAFORM-DOCUMENTATION.md)  
**Diagrams:** [`../../../labs/week3-containerized-oke/docs/WEEK3-TERRAFORM-DIAGRAMS.md`](../../../labs/week3-containerized-oke/docs/WEEK3-TERRAFORM-DIAGRAMS.md)  
**Status:** Applied in stages, validated, then **destroyed** (2026-08-16). Do **not** apply from this note unless you intend another lab session with a same-day destroy.

Never commit `terraform.tfvars`.

---

## Layout

```text
versions.tf  providers.tf  variables.tf  locals.tf
network.tf   # module.network (VCN + IGW + NAT + SGW + shared log group)
subnets.tf   # module.subnet for_each (lb, workers, pods)
oke.tf       # module.oke (count = enable_oke)
outputs.tf
modules/network/   # VCN core (not a module per gateway; subnets stay separate)
modules/subnet/    # subnet + RT + SL + Enable Logs
modules/oke/       # cluster + OCI_VCN_IP_NATIVE + managed node pool (+ NSGs)
k8s/               # kubectl after the cluster exists (not a Terraform module)
```

`module.oke` is gated by `enable_oke`. NSGs stay inside the OKE module (`nsg.tf`), not a separate root module. `module.network` has no count wrapper.

---

## Remote state (planned)

`backend.tf` configures the Terraform `s3` backend against OCI Object
Storage's S3-compatible API, storing state at
`w-terraform-state-intern18/week3-containerized-oke/terraform.tfstate`
instead of a local `terraform.tfstate`. This is not active until the
one-time setup below is done:

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

## Usage (staged)

```powershell
cd terraform/nonprd/week3-containerized-oke
copy terraform.tfvars.example terraform.tfvars
# fill: compartment_ocid, allowed_ssh_cidr, ssh_public_key

terraform init
terraform fmt -recursive
terraform validate

# Stage A — network only
# enable_oke = false
terraform plan
terraform apply

# Stage B — cluster
# enable_oke = true
terraform plan
terraform apply

# kubeconfig then kubectl (Windows order)
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/storageclass.yaml   # cluster oci-bv may reject parameter updates — expected
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml     # image: docker.io/library/nginx:alpine
kubectl apply -f k8s/service.yaml
```

Delete Service + PVC **before** `terraform destroy`.

Details, evidence, and screenshots: the lab Terraform documentation linked above.
