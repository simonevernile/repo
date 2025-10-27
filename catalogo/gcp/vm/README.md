# GCP Virtual Machine Module

[[_TOC_]]

## Resource Schema
The module creates a Compute Engine instance backed by a separate persistent disk. Managed resources are:

- A zonal `google_compute_disk` used as the instance boot disk.
- A `google_compute_instance` attached to the provided network and subnetwork.
- Optional additional `google_compute_disk` resources attached as data disks.

No Cloud KMS resources or additional services are provisioned.

## Notes
Prerequisites:

- An existing GCP project with the **Compute Engine** API enabled.
- A VPC network and subnetwork available in the chosen region/zone.
- Permissions to create Compute Engine resources (e.g. `roles/compute.admin`).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | Unpinned |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | Unpinned (tested with >= 5.0) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where resources will be deployed. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region for regional operations used by the provider. | `string` | `"europe-central2"` | no |
| <a name="input_zone"></a> [zone](#input_zone) | Zone for the VM and disk. | `string` | `"europe-central2-a"` | no |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name) | Compute Engine instance name. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine_type](#input_machine_type) | Machine type (e.g. `e2-standard-2`). | `string` | `"e2-standard-2"` | no |
| <a name="input_boot_disk"></a> [boot_disk](#input_boot_disk) | Boot disk configuration including the disk name plus optional size/type overrides. | `object({ name = string, size = optional(number, 10), type = optional(string, "pd-standard") })` | n/a | yes |
| <a name="input_boot_disk_image"></a> [boot_disk_image](#input_boot_disk_image) | Image used to initialize the boot disk. Accepts full self links or family references. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input_network) | Network self link or name. | `string` | `"default"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input_subnetwork) | Subnetwork self link or name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | Network tags assigned to the instance. | `list(string)` | `[]` | no |
| <a name="input_firewall_tags"></a> [firewall_tags](#input_firewall_tags) | Extra network tags matching pre-existing firewall rules. | `list(string)` | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input_metadata) | Metadata key/value pairs attached to the instance. | `map(string)` | `{}` | no |
| <a name="input_metadata_startup_script"></a> [metadata_startup_script](#input_metadata_startup_script) | Startup script executed on boot. | `string` | `null` | no |
| <a name="input_additional_disks"></a> [additional_disks](#input_additional_disks) | List of extra persistent disks to create and attach. | `list(object({ name = string, size = optional(number), type = optional(string), mode = optional(string), device_name = optional(string) }))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_private_ip"></a> [vm_private_ip](#output_vm_private_ip) | Private IP address of the VM primary interface. |
| <a name="output_vm_name"></a> [vm_name](#output_vm_name) | Name of the created instance. |
| <a name="output_instance_self_link"></a> [instance_self_link](#output_instance_self_link) | Self link of the Compute Engine instance. |

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.boot](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.my_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_disk.additional](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |

## Usage
```hcl
resource "random_password" "implementazione" {
  length           = 16
  special          = true
  override_special = "!@#%^*-_=+"
}

module "vm" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "infra-vm-01"
  network    = "default"
  subnetwork = "default"

  boot_disk = {
    name = "infra-vm-01-boot"
  }

  boot_disk_image = "projects/debian-cloud/global/images/family/debian-12"

  tags = ["restricted-ssh", "http-service"]
  firewall_tags = ["allow-internal"]

  additional_disks = [
    {
      name = "infra-vm-01-data"
      size = 50
      type = "pd-balanced"
    }
  ]
  metadata = {
    "block-project-ssh-keys" = "TRUE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    user="Implementazione"
    password="${random_password.implementazione.result}"

    if ! id "$user" >/dev/null 2>&1; then
      useradd --create-home "$user"
    fi

    echo "$user:$password" | chpasswd

    echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
    chmod 440 "/etc/sudoers.d/$user"
  EOT
}

output "ssh_user" {
  value       = "Implementazione"
  description = "Username created on the VM"
}

output "ssh_password" {
  value       = random_password.implementazione.result
  sensitive   = true
  description = "Password assigned to the SSH user"
}
```

The `random_password` resource above generates credentials that are injected into the instance on first boot. Store the resulting password securely because it is also kept in Terraform state.

## Alternate Usage
<details>
<summary>Customize machine type, disk and networking.</summary>

```hcl
module "vm_custom" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "api-01"
  network    = "default"
  subnetwork = "services-subnet"

  boot_disk = {
    name = "api-01-boot"
    size = 50
    type = "pd-ssd"
  }

  boot_disk_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"

  region = "europe-west1"
  zone   = "europe-west1-b"

  machine_type = "e2-highmem-2"
  tags = ["api", "private"]
}
```
</details>

## Contributing
* setup pre-commit

    ```bash
    pip3 install pre-commit
    ```

* install hooks

    ```bash
    pre-commit install
    ```

* (Optional) - Run against all the files

    ```bash
    pre-commit run --all-files
    ```
