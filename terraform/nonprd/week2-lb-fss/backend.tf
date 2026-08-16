# Remote state via OCI Object Storage's S3-compatible API. See
# ../bootstrap-state/README.md to create the bucket first, and this stack's
# README "Remote state" section for the full one-time setup.
#
# Terraform backend blocks only accept LITERAL values — variables and locals
# are not allowed here. After running the bootstrap stack once, either:
#   (a) replace <namespace> below with the real namespace output and re-run
#       `terraform init -reconfigure`, or
#   (b) leave this block as `backend "s3" {}` (no args) and pass values via
#       `terraform init -backend-config=backend.hcl` using a local, gitignored
#       backend.hcl copied from backend.hcl.example.
#
# Credentials: the s3 backend authenticates with an OCI Customer Secret Key
# via AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env vars (never committed).

terraform {
  backend "s3" {
    bucket                      = "w-terraform-state-intern18"
    key                         = "week2-lb-fss/terraform.tfstate"
    region                      = "me-jeddah-1"
    endpoint                    = "https://<namespace>.compat.objectstorage.me-jeddah-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
