# GCP Virtual Machine Module

[[_TOC_]]

## Resource Schema
The module creates a Compute Engine virtual machine with a boot disk encrypted by Cloud KMS and an existing VPC network. The resources managed directly are:

- Key Ring and Crypto Key on Cloud KMS dedicated to the VM.
- Boot disk encrypted with the newly created key.
- Compute Engine instance with a network interface attached to the provided VPC and an optional public IP.

## Notes
Prerequisites:

- An existing GCP project with the **Compute Engine** and **Cloud KMS** APIs enabled.
- Permissions on the project to create Compute Engine and KMS resources (typically `roles/compute.admin` and `roles/cloudkms.admin`).
- A VPC network available with a name or self link matching the `network` value.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | Unpinned (tested with >= 4.0.0) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where resources will be deployed. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Primary region for the provider and ancillary resources. | `string` | `"us-central1"` | no |
| <a name="input_zone"></a> [zone](#input_zone) | Zone for the VM and boot disk. | `string` | `"us-central1-a"` | no |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name) | Compute Engine instance name. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine_type](#input_machine_type) | Machine type (e.g. `e2-medium`, `n1-standard-1`). | `string` | `"n1-standard-1"` | no |
| <a name="input_disk_size"></a> [disk_size](#input_disk_size) | Boot disk size in GB. | `number` | `10` | no |
| <a name="input_disk_type"></a> [disk_type](#input_disk_type) | Boot disk type (`pd-standard`, `pd-ssd`). | `string` | `"pd-standard"` | no |
| <a name="input_image"></a> [image](#input_image) | Image used to initialize the boot disk. | `string` | `"debian-9-stretch-v20191210"` | no |
| <a name="input_network"></a> [network](#input_network) | Name or self link of the VPC network for the interface. | `string` | `"default"` | no |
| <a name="input_location"></a> [location](#input_location) | KMS Key Ring location. | `string` | `"global"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ip"></a> [vm_ip](#output_vm_ip) | Public IP address assigned to the VM. |
| <a name="output_vm_private_ip"></a> [vm_private_ip](#output_vm_private_ip) | Private IP address of the VM primary interface. |

## Resources

| Name | Type |
|------|------|
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_crypto_key.crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_compute_disk.my_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.my_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Usage
```hcl
module "vm" {
  source       = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id   = var.project_id
  vm_name      = "web-01"
  zone         = "europe-west1-b"
  machine_type = "e2-medium"
}
```

## Alternate Usage
<details>
<summary>VM with customized parameters.</summary>

```hcl
module "vm_custom" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "api-01"

  region = "europe-west1"
  zone   = "europe-west1-b"

  machine_type = "e2-highmem-2"
  disk_size    = 50
  disk_type    = "pd-ssd"
  image        = "projects/debian-cloud/global/images/debian-12-bookworm-v20240110"

  network  = "shared-vpc"
  location = "europe-west1"
}
```
</details>

## Notes on KMS & Networking
- The Key Ring and Crypto Key are created with default names (`my-key-ring`, `my-key`). Adjust the code if you need naming aligned with company standards.
- The network interface receives a public IP through the `access_config` block. Remove it if you need a private-only VM.

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
