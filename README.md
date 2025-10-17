
# Terraform GCP Modules

Welcome to the **Terraform GCP Modules** repository! This repository contains reusable Terraform modules designed to provision resources on Google Cloud Platform (GCP). These modules are organized for specific resources such as Virtual Machines (VMs), Firewall Rules, and Load Balancers.

## Modules Overview

| Module         | Description                                                      | Key Variables                                                        | Required Variables               | Optional Variables               | Documentation Link                                            |
|----------------|------------------------------------------------------------------|----------------------------------------------------------------------|----------------------------------|-----------------------------------|-------------------------------------------------------------|
| **VM**          | Creates a Google Cloud Virtual Machine (VM) with encryption.      | `vm_name`, `zone`, `machine_type`, `disk_size`, `network`             | `vm_name`, `zone`                | `machine_type`, `disk_size`, `disk_type`, `image`, `network` | [VM Module Docs](https://github.com/simonevernile/repo/blob/main/vm/docs/doc.md) |
| **Firewall**    | Configures firewall rules for public and local traffic control.  | `network`, `target_tags`, `local_range`, `ssh_tags`, `allow_http`     | `network`, `target_tags`, `local_range`, `ssh_tags` | `allow_http`, `allow_https` | [Firewall Module Docs](https://github.com/simonevernile/repo/blob/main/firewall/docs/doc.md) |
| **Load Balancer** | Provisions public and private load balancers.                   | `region`, `network`, `allow_http`, `allow_https`                      | `region`                         | `network`, `allow_http`, `allow_https` | [Load Balancer Module Docs](https://github.com/simonevernile/repo/blob/main/load%20balancer/docs/doc.md) |

## Getting Started

To use any of the modules in this repository, you need to clone this repository and configure the necessary variables for each module.

### 1. Clone the repository

```bash
git clone https://github.com/simonevernile/repo.git
cd repo
```

### 2. Configure your variables

You need to create a `variables.tf` file for your specific use case. For example, for creating a VM, you can configure the following variables:

```hcl
module "vm" {
  source    = "./modules/vm"
  vm_name   = "my-vm"
  zone      = "us-central1-a"
  machine_type = "n1-standard-1"
}
```

### 3. Initialize Terraform

Once you've configured the variables, run the following command to initialize the Terraform working directory:

```bash
terraform init
```

### 4. Apply the configuration

After initializing, run the following command to apply the configuration and create the resources:

```bash
terraform apply
```

Terraform will show you a plan of the actions it will take. Type `yes` to apply the plan and create the resources.

## Available Modules

### **1. VM Module**

The VM module creates a Google Cloud Virtual Machine with the ability to encrypt the disk using a custom KMS key.

**Input Variables:**
- `vm_name` (Required)
- `zone` (Required)
- `machine_type` (Optional, default: `n1-standard-1`)
- `disk_size` (Optional, default: `10`)
- `disk_type` (Optional, default: `pd-standard`)
- `image` (Optional, default: `debian-9-stretch-v20191210`)

**Outputs:**
- `vm_ip` (Public IP address)
- `vm_private_ip` (Private IP address)

### **2. Firewall Module**

The Firewall module allows you to set up firewall rules for controlling access to your resources in GCP.

**Input Variables:**
- `network` (Required)
- `target_tags` (Required)
- `local_range` (Required)
- `ssh_tags` (Required)
- `allow_http` (Optional, default: `true`)
- `allow_https` (Optional, default: `true`)

**Outputs:**
- `public_http_firewall`
- `local_ssh_firewall`

### **3. Load Balancer Module**

This module sets up both public and private load balancers in GCP.

**Input Variables:**
- `region` (Required)
- `network` (Optional, default: `default`)
- `allow_http` (Optional, default: `true`)
- `allow_https` (Optional, default: `true`)

**Outputs:**
- `public_ip` (Public IP address)
- `private_ip` (Private IP address)

## Contributing

If you find any issues or would like to contribute improvements to these modules, feel free to fork the repository and submit a pull request. All contributions are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
