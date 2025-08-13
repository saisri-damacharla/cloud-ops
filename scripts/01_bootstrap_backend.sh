#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
BUCKET="${BUCKET:-YOUR_TF_STATE_BUCKET}"
LOCATION="${LOCATION:-US}"

pushd terraform/backend >/dev/null

terraform init
terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="bucket_name=${BUCKET}" \
  -var="location=${LOCATION}"

popd >/dev/null

echo "Bootstrap complete. Use bucket: ${BUCKET} in terraform/infra backend."
