# Terraform GCP Modules

Reusable Terraform modules for provisioning resources on Google Cloud Platform (GCP). Each module targets a specific resource type and ships with dedicated documentation covering variables, outputs, and usage examples.

## Modules Overview

| Module | Description | Required variables | Key optional variables | Documentation |
| --- | --- | --- | --- | --- |
| **VM** | Creates a Virtual Machine with an encrypted boot disk and configurable parameters. | `project_id`, `vm_name` | `zone`, `machine_type`, `disk_size`, `disk_type`, `image`, `network`, `location` | [VM documentation](catalogo/gcp/vm/README.md) |
| **Firewall** | Configures firewall rules for public and private traffic to GCP resources. | `network`, `target_tags`, `local_range`, `ssh_tags` | `allow_http`, `allow_https` | [Firewall documentation](catalogo/gcp/firewall/README.md) |
| **Load Balancer** | Manages external and internal load balancers from a single list. | `project_id`, `load_balancers[*].name_prefix`, `load_balancers[*].type`, `load_balancers[*].region` | `load_balancers[*].network`, `subnetwork`, `address`, `tcp_ports`, `udp_ports`, `backend_zone`, `backend_ig`, `labels`, `enabled` | [Load Balancer documentation](catalogo/gcp/load_balancer/README.md) |

## Quickstart

1. **Clone the repository**
   ```bash
   git clone https://github.com/simonevernile/repo-tf.git
   cd repo-tf
   ```
2. **Configure variables**
   - Define `*.tfvars` files or set variables directly in the modules, depending on your use case.
3. **Initialize Terraform**
   ```bash
   terraform init
   ```
4. **Apply the configuration**
   ```bash
   terraform apply
   ```
   Review the generated plan and confirm by typing `yes` to create the resources.

## Usage Examples

### VM Module
```hcl
module "vm" {
  source       = "git::https://github.com/simonevernile/repo-tf.git//catalogo/gcp/vm?ref=main"
  project_id   = var.project_id
  vm_name      = "my-vm"
  zone         = "us-central1-a"
  machine_type = "e2-medium"
}
```

### Firewall Module
```hcl
module "firewall" {
  source      = "git::https://github.com/simonevernile/repo-tf.git//catalogo/gcp/firewall?ref=main"
  network     = "default"
  target_tags = ["web"]
  local_range = "10.128.0.0/20"
  ssh_tags    = ["ssh"]
  allow_http  = true
  allow_https = true
}
```

### Load Balancer Module
```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo-tf.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "app-ext"
      type        = "external"
      region      = "europe-west1"
      tcp_ports   = [80, 443]
      labels      = { app = "frontend" }
    },
    {
      name_prefix  = "app-int"
      type         = "internal"
      region       = "europe-west1"
      network      = "default"
      subnetwork   = "default"
      tcp_ports    = [8080, 8443]
      backend_zone = "europe-west1-b"
      labels       = { app = "backend" }
    }
  ]
}
```

## Contributing

If you encounter issues or want to propose improvements to the modules, open an *issue* or submit a *pull request*. Contributions are welcome!

## License

This project is distributed under the MIT license. See [LICENSE](LICENSE) for details.
