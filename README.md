# Real-Time GCP Cloud Ops Showcase (Terraform + GKE + Pub/Sub + Cloud Build)

This repo is a **end-to-end Cloud Operations project** that demonstrates:

- Terraform with remote state in **GCS**
- **GKE** cluster (Workload Identity), **Artifact Registry**, **Pub/Sub**
- App containerization with **Docker** and CI using **Cloud Build**
- **Secret Manager** for secrets + GKE Workload Identity
- Monitoring & Alerts (uptime checks + CPU alerts)
- Clear step-by-step instructions

> Target audience: Hiring managers evaluating a 4-year Cloud Ops engineer skillset.

---

## 🗂️ Repository Layout

```
terraform/
  backend/          # Bootstraps GCS bucket for Terraform state
  infra/            # Main infrastructure (GKE, Artifact Registry, Pub/Sub, IAM, Monitoring)
app/
  publisher/        # Flask API publishes messages to Pub/Sub
  worker/           # Worker consumes Pub/Sub messages
k8s/                # Kubernetes manifests (namespace, svc accounts, deployments, services, HPA)
cloudbuild/
  cloudbuild.yaml   # Builds & pushes images; can apply manifests (optional step)
scripts/
  01_bootstrap_backend.sh
  02_init_apply.sh
  03_build_and_deploy.sh
```

---

## ⏱️ 6-Hour Implementation Plan

### 0) Prereqs (15 min)
- Install: `gcloud`, `terraform`, `kubectl`, `docker`
- Auth: `gcloud auth login && gcloud auth application-default login`
- Set project: `gcloud config set project <PROJECT_ID>`
- Enable required APIs (Terraform also enables them): `gcloud services enable container.googleapis.com artifactregistry.googleapis.com pubsub.googleapis.com secretmanager.googleapis.com monitoring.googleapis.com cloudbuild.googleapis.com`

### 1) Bootstrap Terraform Backend (15–20 min)
```bash
cd terraform/backend
terraform init
terraform apply -auto-approve -var='project_id=<PROJECT_ID>' -var='bucket_name=<STATE_BUCKET_NAME>' -var='location=US'
```
Copy the printed backend values into `terraform/infra/backend.tf` (already templated to use your provided bucket name variable).

### 2) Provision Infra (45–60 min)
```bash
cd ../../terraform/infra
# create terraform.tfvars with your settings (see example in this folder)
terraform init
terraform apply -auto-approve
```
This creates:
- VPC/Subnet, GKE (Autopilot off; standard node pool), Workload Identity
- Artifact Registry repo, Pub/Sub topic & subscription
- Secret Manager secret, Monitoring notification channel + alerts

### 3) Build & Push Images (20–30 min)
Option A: Cloud Build (recommended)
```bash
gcloud builds submit --config=cloudbuild/cloudbuild.yaml --substitutions=_REGION=<REGION>,_REPO=<AR_REPO_NAME>,_PROJECT_ID=<PROJECT_ID>
```

Option B: Local Docker then push to Artifact Registry:
```bash
REGION=<REGION>
REPO=<AR_REPO_NAME>
PROJECT_ID=<PROJECT_ID>

gcloud auth configure-docker ${REGION}-docker.pkg.dev -q

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/publisher:latest ./app/publisher
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/publisher:latest

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/worker:latest ./app/worker
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/worker:latest
```

### 4) Deploy to GKE (20–30 min)
```bash
# Get kubeconfig
gcloud container clusters get-credentials $(terraform output -raw cluster_name) --region $(terraform output -raw region) --project $(terraform output -raw project_id)

# Create namespace, service accounts & RBAC
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/service-accounts.yaml
kubectl apply -f k8s/rbac.yaml

# Bind KSA to GSA for Workload Identity (publisher + worker)
# The Terraform output prints GSA emails; update annotations if you changed names.

# Deploy apps
kubectl apply -f k8s/deployment-publisher.yaml
kubectl apply -f k8s/service-publisher.yaml
kubectl apply -f k8s/hpa-publisher.yaml
kubectl apply -f k8s/deployment-worker.yaml
```

### 5) Test (10–15 min)
- Get service external IP: `kubectl get svc -n ops-demo`
- Publish message: `curl -X POST http://<EXTERNAL_IP>/publish -H "x-api-key: demo-key" -d '{"payload":"hello"}' -H "Content-Type: application/json"`
- Check worker logs: `kubectl logs -l app=worker -n ops-demo`

### 6) Monitoring & Alerts (10–15 min)
- Terraform created an **uptime check** and **CPU alert** with email channel.
- Trigger some load (looped curl) to see HPA scale and receive notifications.

### 7) Cleanup (10 min)
```bash
# Delete K8s resources
kubectl delete ns ops-demo
# Tear down infra
cd terraform/infra && terraform destroy
# Optionally delete the remote state bucket (from backend/)
```

---

## 📦 terraform/backend (Bootstrap)

Creates the GCS bucket for Terraform state and a locking mechanism via uniform bucket-level access.

**Usage**
```bash
terraform apply -auto-approve -var='project_id=...' -var='bucket_name=...' -var='location=US'
```

---

## 🔐 Secrets

- Secret Manager holds `APP_API_KEY` (sample value is `demo-key`).
- GKE Pods use **Workload Identity** and Google client libs to access Secret Manager at runtime (no static K8s Secrets committed).

---

## 🛠️ Cloud Build

`cloudbuild/cloudbuild.yaml` builds and pushes both images. You can extend it to `kubectl apply` on success by granting the Cloud Build SA GKE access.

---

## ✅ What You’ll Be Able to Show

- Proper Terraform state management
- Production-ready GKE setup with Workload Identity
- CI with Cloud Build, containerization best practices
- Secure secrets access from workloads
- Pub/Sub async patterns (publisher + worker)
- Observability: uptime check, alerts, HPA

Good luck — ship it! 🚀
