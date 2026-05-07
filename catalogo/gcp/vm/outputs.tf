output "vm_private_ip" {
  description = "The private IP address of the VM"
  value       = google_compute_instance.my_vm.network_interface[0].network_ip
}

output "vm_public_ip" {
  description = "The public IP attached to the VM, or null when assign_public_ip is false."
  value       = try(google_compute_instance.my_vm.network_interface[0].access_config[0].nat_ip, null)
}

output "vm_name" {
  description = "The name of the VM"
  value       = google_compute_instance.my_vm.name
}

output "instance_id" {
  description = "Numeric ID assigned by GCP to the instance."
  value       = google_compute_instance.my_vm.instance_id
}

output "instance_self_link" {
  description = "The self link of the VM instance."
  value       = google_compute_instance.my_vm.self_link
}

output "boot_disk_self_link" {
  description = "Self link of the boot disk."
  value       = google_compute_disk.boot.self_link
}

output "additional_disk_self_links" {
  description = "Map of additional disk name → self link."
  value       = { for k, v in google_compute_disk.additional : k => v.self_link }
}

output "service_account_email" {
  description = "Service account email associated with the VM, or null when none configured."
  value       = try(google_compute_instance.my_vm.service_account[0].email, null)
}
