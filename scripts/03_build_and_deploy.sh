#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
REGION="${REGION:-us-central1}"
REPO="${REPO:-ops-images}"

gcloud auth configure-docker ${REGION}-docker.pkg.dev -q

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/publisher:latest ./app/publisher
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/publisher:latest

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/worker:latest ./app/worker
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/worker:latest

# Kubeconfig
CLUSTER_NAME=$(terraform -chdir=terraform/infra output -raw cluster_name)
REGION_OUT=$(terraform -chdir=terraform/infra output -raw region)
PROJECT_OUT=$(terraform -chdir=terraform/infra output -raw project_id)

gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION_OUT" --project "$PROJECT_OUT"

# Render K8s manifests with your values
for f in k8s/*.yaml; do
  sed -i "s/PROJECT_ID/${PROJECT_OUT}/g" "$f"
  sed -i "s/REGION/${REGION}/g" "$f"
  sed -i "s/REPO/${REPO}/g" "$f"
done

kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/service-accounts.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/deployment-publisher.yaml
kubectl apply -f k8s/service-publisher.yaml
kubectl apply -f k8s/hpa-publisher.yaml
kubectl apply -f k8s/deployment-worker.yaml

echo "Deployment initiated. Check service external IP:"
echo "kubectl get svc -n ops-demo"
