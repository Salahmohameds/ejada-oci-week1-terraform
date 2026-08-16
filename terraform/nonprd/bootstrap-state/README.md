# Bootstrap: Terraform remote-state bucket (Object Storage)

Creates the **one** Object Storage bucket that holds remote Terraform state
for the other nonprd stacks (`week2-lb-fss`, `week3-containerized-oke`, ...).
Object Storage exposes an S3-compatible API, so those stacks configure the
standard Terraform `s3` backend pointed at this bucket instead of writing a
local `terraform.tfstate`.

## Why this stack keeps LOCAL state

This is the one deliberate exception to "state lives in the bucket": the
bucket has to exist *before* anything can write state into it, so this stack
cannot store its own state remotely (chicken-and-egg). Its `terraform.tfstate`
stays local and gitignored, same as any other Terraform state file. It is a
tiny, rarely-changed stack (one bucket), so the risk of not having remote
state for it is low.

## Layout

```text
bootstrap-state/
  versions.tf   providers.tf   variables.tf
  main.tf       # data.oci_objectstorage_namespace + oci_objectstorage_bucket
  outputs.tf    # namespace, bucket name/OCID, s3-compatible endpoint
  terraform.tfvars.example
  README.md
```

## One-time setup (run manually, once)

```bash
cd terraform/nonprd/bootstrap-state
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: compartment_ocid (and state_bucket_name if you want
# a different bucket name than the default)

terraform init
terraform plan
terraform apply
```

After `apply`, note the outputs:

- `namespace` — Object Storage namespace, needed by every stack's `backend.tf`
- `state_bucket_name` — bucket name (defaults to `w-terraform-state-intern18`)
- `s3_compatible_endpoint` — full endpoint URL for the `s3` backend `endpoint` argument

Then fill those values into `week2-lb-fss/backend.tf` and
`week3-containerized-oke/backend.tf` (or their `backend.hcl` — see each
stack's README) and run `terraform init -reconfigure` in each stack.

## Credentials for the S3-compatible backend

The `s3` backend authenticates with an **OCI Customer Secret Key**
(S3-compatible access key/secret pair), not the OCI config profile used by
the `oci` provider above. Generate one for your user, once, via the OCI
Console (Identity → Users → your user → Customer Secret Keys → Generate
Secret Key) or the CLI:

```bash
oci iam customer-secret-key create --user-id <your-user-ocid> --display-name terraform-backend-key
```

This prints an access key and secret key **once**. Store them only as local
environment variables — never in a committed file:

```powershell
$env:AWS_ACCESS_KEY_ID     = "<customer-secret-key access key>"
$env:AWS_SECRET_ACCESS_KEY = "<customer-secret-key secret key>"
```

## Bucket already exists?

If a bucket named `w-terraform-state-intern18` already exists in the
compartment (e.g. created once directly via `oci os bucket create` while
this Terraform code was being written), either:

- delete it and let `terraform apply` create it fresh from this code, or
- `terraform import oci_objectstorage_bucket.terraform_state <namespace>/<bucket-name>`
  to bring the existing bucket under Terraform management (then `terraform
  plan` should show no changes, or only `versioning` if it wasn't enabled
  manually).

Do not leave an unmanaged, hand-created bucket alongside this code long-term.

## Destroy

Only destroy this stack after no other stack's backend still points at the
bucket (destroying it would delete all remote state). Not expected to be
destroyed during normal lab lifecycle.
