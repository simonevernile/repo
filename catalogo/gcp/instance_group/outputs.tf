output "name" {
  description = "Instance group name."
  value       = google_compute_instance_group.ig.name
}

output "id" {
  description = "Resource ID of the instance group."
  value       = google_compute_instance_group.ig.id
}

output "instance_self_link" {
  description = "Self link of the instance group. Use this as the backend group of an internal/network LB."
  value       = google_compute_instance_group.ig.self_link
}

output "size" {
  description = "Number of instances currently in the group."
  value       = google_compute_instance_group.ig.size
}
