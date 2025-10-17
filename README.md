# Terraform GCP Modules

Welcome to the **Terraform GCP Modules** repository! This repository contains reusable Terraform modules designed to provision resources on Google Cloud Platform (GCP). These modules are organized for specific resources such as Virtual Machines (VMs), Firewall Rules, and Load Balancers.

## Modules Overview

| Module         | Description                                                      | Key Variables                                                        | Required Variables               | Optional Variables               |
|----------------|------------------------------------------------------------------|----------------------------------------------------------------------|----------------------------------|-----------------------------------|
| **VM**          | Creates a Google Cloud Virtual Machine (VM) with encryption.      | `vm_name`, `zone`, `machine_type`, `disk_size`, `network`             | `vm_name`, `zone`                | `machine_type`, `disk_size`, `disk_type`, `image`, `network` |
| **Firewall**    | Configures firewall rules for public and local traffic control.  | `network`, `target_tags`, `local_range`, `ssh_tags`, `allow_http`     | `network`, `target_tags`, `local_range`, `ssh_tags` | `allow_http`, `allow_https` |
| **Load Balancer** | Provisions public and private load balancers.                   | `region`, `network`, `allow_http`, `allow_https`                      | `region`                         | `network`, `allow_http`, `allow_https` |

## Getting Started

To use any of the modules in this repository, you need to clone this repository and configure the necessary variables for each module.
