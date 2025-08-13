variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "bucket_name" {
  description = "GCS bucket name for Terraform state"
  type        = string
}
variable "location" {
  description = "Bucket location (e.g., US)"
  type        = string
  default     = "US"
}
