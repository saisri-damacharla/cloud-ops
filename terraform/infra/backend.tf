# Replace bucket in terraform.tfvars via variable; this form uses partial backend config for clarity.
terraform {
  backend "gcs" {
    # bucket = "REPLACE_WITH_YOUR_STATE_BUCKET"  # set via init -backend-config or manually
    # prefix = "tfstate/infra"
  }
}
