output "vm_ip" {
  description = "The public IP address of the VM"
  value       = google_compute_instance.my_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_private_ip" {
  description = "The private IP address of the VM"
  value       = google_compute_instance.my_vm.network_interface[0].network_ip
}