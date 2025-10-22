output "vm_private_ip" {
  description = "The private IP address of the VM"
  value       = google_compute_instance.my_vm.network_interface[0].network_ip
}

output "vm_name" {
  description = "The name of the VM"
  value       = google_compute_instance.my_vm.name
}

output "instance_self_link" {
  description = "The self link of the VM instance"
  value       = google_compute_instance.my_vm.self_link
}
