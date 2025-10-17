# VM Module Documentation

## Overview
This module creates a Google Cloud Virtual Machine (VM) with an encrypted boot disk using a custom Key Management Service (KMS) key. You can configure the machine type, disk size, and image to be used.

## Input Variables

### **Required Variables**
These variables **must** be provided to use this module.

#### `vm_name`
- **Description**: The name of the virtual machine.
- **Type**: `string`

#### `zone`
- **Description**: The zone where the virtual machine will be created.
- **Type**: `string`

#### `network`
- **Description**: The network the VM will be attached to.
- **Type**: `string`
- **Default**: `default`

### **Optional Variables**
These variables are **optional** and can be left unset. Default values will be used if not provided.

#### `machine_type`
- **Description**: The machine type for the VM (e.g., `n1-standard-1`, `e2-medium`).
- **Type**: `string`
- **Default**: `n1-standard-1`

#### `disk_size`
- **Description**: The size of the boot disk in GB.
- **Type**: `number`
- **Default**: `10`

#### `disk_type`
- **Description**: The type of disk to be created (`pd-standard`, `pd-ssd`).
- **Type**: `string`
- **Default**: `pd-standard`

#### `image`
- **Description**: The image to initialize the VM’s boot disk (e.g., `debian-9-stretch-v20191210`).
- **Type**: `string`
- **Default**: `debian-9-stretch-v20191210`

#### `location`
- **Description**: The location for the KMS key ring.
- **Type**: `string`
- **Default**: `global`

## Output Values
### `vm_ip`
- **Description**: The **public** IP address of the VM.
- **Type**: `string`

### `vm_private_ip`
- **Description**: The **private** IP address of the VM.
- **Type**: `string`

## Usage Example

```hcl
module "vm" {
  source    = "./modules/vm"
  vm_name   = "my-vm"
  zone      = "us-central1-a"
  machine_type = "n1-standard-1"
}
