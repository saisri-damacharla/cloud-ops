variable "project_id" {
  type        = string
  description = "GCP project ID"
}
variable "region" {
  type        = string
  description = "GCP region, e.g. us-central1"
  default     = "us-central1"
}
variable "zone" {
  type        = string
  description = "GCP zone, e.g. us-central1-a"
  default     = "us-central1-a"
}
variable "network_name" {
  type        = string
  default     = "ops-vpc"
}
variable "subnet_cidr" {
  type        = string
  default     = "10.20.0.0/16"
}
variable "cluster_name" {
  type        = string
  default     = "ops-gke"
}
variable "min_nodes" {
  type        = number
  default     = 1
}
variable "max_nodes" {
  type        = number
  default     = 3
}
variable "artifact_repo" {
  type        = string
  default     = "ops-images"
}
variable "secret_name" {
  type        = string
  default     = "APP_API_KEY"
}
variable "secret_value" {
  type        = string
  default     = "demo-key"
  sensitive   = true
}
variable "notification_email" {
  type        = string
  description = "Email for alert notifications"
}
variable "state_bucket" {
  type        = string
  description = "Existing GCS bucket name for Terraform state (from backend bootstrap)"
}
