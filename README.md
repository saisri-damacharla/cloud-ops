# Real-Time GCP Cloud Ops Showcase (Terraform + GKE + Pub/Sub + Cloud Build)

This repo is a **end-to-end Cloud Operations project** that demonstrates:

- Terraform with remote state in **GCS**
- **GKE** cluster (Workload Identity), **Artifact Registry**, **Pub/Sub**
- App containerization with **Docker** and CI using **Cloud Build**
- **Secret Manager** for secrets + GKE Workload Identity
- Monitoring & Alerts (uptime checks + CPU alerts)



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
  cloudbuild.yaml   # Builds & pushes images; can apply manifests 
scripts/
  01_bootstrap_backend.sh
  02_init_apply.sh
  03_build_and_deploy.sh
```

---
