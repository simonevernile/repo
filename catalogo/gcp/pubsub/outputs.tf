output "topic_id" {
  description = "Resource ID of the topic (projects/.../topics/<name>)."
  value       = google_pubsub_topic.topic.id
}

output "topic_name" {
  description = "Topic name."
  value       = google_pubsub_topic.topic.name
}

output "subscription_ids" {
  description = "Map of subscription name → resource ID."
  value       = { for k, v in google_pubsub_subscription.subscriptions : k => v.id }
}
