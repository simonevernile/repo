# GCP Virtual Machine Module

[[_TOC_]]

## Resource Schema
The module creates a Compute Engine instance backed by a separate persistent disk. Managed resources are:

- A zonal `google_compute_disk` used as the instance boot disk.
- A `google_compute_instance` attached to the provided network and subnetwork.

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
| <a name="input_disk_name"></a> [disk_name](#input_disk_name) | Name of the boot disk to create. | `string` | n/a | yes |
| <a name="input_disk_size"></a> [disk_size](#input_disk_size) | Boot disk size in GB. | `number` | `10` | no |
| <a name="input_disk_type"></a> [disk_type](#input_disk_type) | Boot disk type (`pd-standard`, `pd-ssd`, ...). | `string` | `"pd-standard"` | no |
| <a name="input_image"></a> [image](#input_image) | Image used to initialize the boot disk. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input_network) | Network self link or name. | `string` | `"default"` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input_subnetwork) | Subnetwork self link or name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | Network tags assigned to the instance. | `list(string)` | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input_metadata) | Metadata key/value pairs attached to the instance. | `map(string)` | `{}` | no |
| <a name="input_metadata_startup_script"></a> [metadata_startup_script](#input_metadata_startup_script) | Startup script executed on boot. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_private_ip"></a> [vm_private_ip](#output_vm_private_ip) | Private IP address of the VM primary interface. |
| <a name="output_vm_name"></a> [vm_name](#output_vm_name) | Name of the created instance. |
| <a name="output_instance_self_link"></a> [instance_self_link](#output_instance_self_link) | Self link of the Compute Engine instance. |

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.my_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.my_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Usage
```hcl
variable "ssh_public_key" {
  description = "Authorized key for the Implementazione user"
  type        = string
}

module "vm" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "infra-vm-01"
  disk_name  = "infra-vm-01-boot"
  image      = "projects/debian-cloud/global/images/family/debian-12"
  subnetwork = "default"

  tags = ["restricted-ssh", "http-service"]
  metadata = {
    "block-project-ssh-keys" = "TRUE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    user="Implementazione"

    if ! id "$user" >/dev/null 2>&1; then
      useradd --create-home "$user"
    fi

    install -d -m 700 "/home/$user/.ssh"
    cat <<'EOF' > "/home/$user/.ssh/authorized_keys"
${var.ssh_public_key}
EOF
    chown -R "$user:$user" "/home/$user/.ssh"
    chmod 600 "/home/$user/.ssh/authorized_keys"

    echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
    chmod 440 "/etc/sudoers.d/$user"
  EOT
}
```

Set `var.ssh_public_key` to the public key that should be authorized for the `Implementazione` user. This value can come from an existing key pair or a Terraform-managed resource such as [`tls_private_key`](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key).

## Alternate Usage
<details>
<summary>Customize machine type, disk and networking.</summary>

```hcl
module "vm_custom" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "api-01"
  disk_name  = "api-01-boot"
  image      = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  subnetwork = "services-subnet"

  region = "europe-west1"
  zone   = "europe-west1-b"

  machine_type = "e2-highmem-2"
  disk_size    = 50
  disk_type    = "pd-ssd"

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
