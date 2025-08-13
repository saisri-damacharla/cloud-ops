resource "google_pubsub_topic" "ops_topic" {
  name = "ops-topic"
}

resource "google_pubsub_subscription" "ops_sub" {
  name  = "ops-sub"
  topic = google_pubsub_topic.ops_topic.name
}
