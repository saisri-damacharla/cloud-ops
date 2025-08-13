#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
REGION="${REGION:-us-central1}"
STATE_BUCKET="${STATE_BUCKET:-YOUR_TF_STATE_BUCKET}"
NOTIFY_EMAIL="${NOTIFY_EMAIL:-you@example.com}"

pushd terraform/infra >/dev/null

# Configure backend on init via -backend-config flags (safer than hardcoding)
terraform init \
  -backend-config="bucket=${STATE_BUCKET}" \
  -backend-config="prefix=tfstate/infra"

cat > terraform.tfvars <<EOF
project_id         = "${PROJECT_ID}"
region             = "${REGION}"
notification_email = "${NOTIFY_EMAIL}"
state_bucket       = "${STATE_BUCKET}"
EOF

terraform apply -auto-approve

popd >/dev/null
