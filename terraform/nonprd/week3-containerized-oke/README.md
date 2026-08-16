# Week 3 — Containerized application / OKE (Terraform)

**Student:** Salah Abdelhady  
**Lab write-up:** [`../../../week3/Week3-Lab3-Terraform-Documentation.pdf`](../../../week3/Week3-Lab3-Terraform-Documentation.pdf)  
**Diagrams:** [`../../../week3/Week3-Terraform-Diagrams.drawio`](../../../week3/Week3-Terraform-Diagrams.drawio)  
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

Details: the lab Terraform documentation linked above.
