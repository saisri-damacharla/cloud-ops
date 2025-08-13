# Notification Channel (email)
resource "google_monitoring_notification_channel" "email" {
  display_name = "Ops Email"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
}

# Uptime Check for publisher service (placeholder host, update after LB IP known)
# You can edit the host once the external IP is assigned.
resource "google_monitoring_uptime_check_config" "publisher_http" {
  display_name = "Publisher HTTP"
  http_check {
    path = "/"
    port = 80
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host = "CHANGE_ME_AFTER_DEPLOY" # Replace with external IP or DNS
    }
  }
  timeout = "10s"
  period  = "60s"
}

# Simple CPU alert on GKE nodes (project-level)
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "High GKE CPU"
  combiner     = "OR"
  conditions {
    display_name = "Node CPU > 80%"
    condition_threshold {
      filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\""
      duration = "300s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.8
      trigger { count = 1 }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.name]
}
