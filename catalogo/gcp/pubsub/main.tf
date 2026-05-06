resource "google_pubsub_topic" "topic" {
  name                       = var.topic
  project                    = var.project_id
  labels                     = var.labels
  message_retention_duration = var.message_retention_duration
  kms_key_name               = var.kms_key_name

  dynamic "message_storage_policy" {
    for_each = length(var.allowed_persistence_regions) > 0 ? [1] : []
    content {
      allowed_persistence_regions = var.allowed_persistence_regions
    }
  }

  dynamic "schema_settings" {
    for_each = var.schema == null ? [] : [var.schema]
    content {
      schema   = schema_settings.value.schema
      encoding = schema_settings.value.encoding
    }
  }
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = { for s in var.subscriptions : s.name => s }

  name                       = each.value.name
  project                    = var.project_id
  topic                      = google_pubsub_topic.topic.id
  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  retain_acked_messages      = each.value.retain_acked_messages
  enable_message_ordering    = each.value.enable_message_ordering
  filter                     = each.value.filter
  labels                     = each.value.labels

  expiration_policy {
    ttl = each.value.expiration_ttl
  }

  retry_policy {
    minimum_backoff = each.value.retry_minimum_backoff
    maximum_backoff = each.value.retry_maximum_backoff
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_topic == null ? [] : [each.value.dead_letter_topic]
    content {
      dead_letter_topic     = dead_letter_policy.value
      max_delivery_attempts = each.value.max_delivery_attempts
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_endpoint == null ? [] : [each.value.push_endpoint]
    content {
      push_endpoint = push_config.value

      dynamic "oidc_token" {
        for_each = each.value.push_oidc_service_account == null ? [] : [each.value.push_oidc_service_account]
        content {
          service_account_email = oidc_token.value
          audience              = each.value.push_oidc_audience
        }
      }
    }
  }
}

resource "google_pubsub_topic_iam_member" "publishers" {
  for_each = toset(var.publishers)

  project = var.project_id
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = each.value
}
