# Terraform GCP Modules

Reusable Terraform modules for provisioning resources on Google Cloud Platform (GCP). Each module targets a specific resource type and ships with dedicated documentation covering variables, outputs, and usage examples.

## Modules Overview

| Module | Description | Required variables | Key optional variables | Documentation |
| --- | --- | --- | --- | --- |
| **VM** | Creates a Compute Engine instance with a dedicated boot disk. | `project_id`, `vm_name`, `boot_disk`, `boot_disk_image`, `subnetwork` | `region`, `zone`, `machine_type`, `network`, `tags`, `additional_disks` | [VM documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/vm/README.md) |
| **Firewall** | Configures firewall rules for public and private traffic to GCP resources. | `network`, `target_tags`, `local_range` | `ssh_tags`, `allow_http`, `allow_https` | [Firewall documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/firewall/README.md) |
| **Load Balancer** | Wraps the external and internal load balancer modules to build multiple LBs from a single list. | `project_id`, `load_balancers[*].name_prefix`, `load_balancers[*].type`, `load_balancers[*].region` | `load_balancers[*].network`, `subnetwork`, `address`, `tcp_ports`, `udp_ports`, `target_pool_instances`, `backend_ig`, `labels`, `enabled` | [Load Balancer documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/load_balancer/README.md) |
| **Cloud SQL MySQL** | Provisions a MySQL Cloud SQL instance with optional root password and database creation. | `project_id`, `instance_name` | `region`, `database_version`, `tier`, `disk_size`, `disk_type`, `availability_type`, `deletion_protection`, `root_password`, `database_name`, `enable_public_ip` | [Cloud SQL MySQL documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/mysql/README.md) |
| **Cloud SQL PostgreSQL** | Provisions a PostgreSQL Cloud SQL instance with configurable storage, availability, optional postgres password, and optional database creation. | `project_id`, `instance_name` | `region`, `database_version`, `tier`, `disk_size`, `disk_type`, `availability_type`, `deletion_protection`, `postgres_password`, `database_name`, `enable_public_ip` | [Cloud SQL PostgreSQL documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/postgres/README.md) |
| **Memorystore Redis** | Creates a Redis instance for caching with optional authentication. | `project_id`, `name` | `region`, `tier`, `memory_size_gb`, `auth_enabled` | [Redis documentation](https://github.com/simonevernile/repo/blob/main/catalogo/gcp/redis/README.md) |

## Quickstart

1. **Clone the repository**
   ```bash
   git clone https://github.com/simonevernile/repo.git
   cd repo
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
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "my-vm"
  network    = "default"
  subnetwork = "default"

  boot_disk = {
    name = "my-vm-boot"
  }

  boot_disk_image = "projects/debian-cloud/global/images/family/debian-12"
}
```

### Firewall Module
```hcl
module "firewall" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall?ref=main"
  network     = "default"
  target_tags = ["web"]
  local_range = ["10.128.0.0/20"]
  ssh_tags    = ["ssh"]
  allow_http  = true
  allow_https = true
}
```

### Load Balancer Module
```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "app-ext"
      type        = "external"
      region      = "europe-west1"
      tcp_ports   = [80, 443]
      target_pool_instances = [module.vm.instance_self_link] # reuse the VM created in the previous example
      labels      = { app = "frontend" }
    },
    {
      name_prefix  = "app-int"
      type         = "internal"
      region       = "europe-west1"
      network      = "default"
      subnetwork   = "default"
      tcp_ports    = [8080, 8443]
      backend_ig   = "projects/${var.project_id}/zones/europe-west1-b/instanceGroups/backend"
      labels       = { app = "backend" }
    }
  ]
}
```

### End-to-end example: Controlled SSH access with an HTTP load balancer

The [examples/main.tf](https://github.com/simonevernile/repo/blob/main/examples/main.tf) configuration composes the modules to:

1. Provision a Compute Engine VM and configure a dedicated `Implementazione` user with passwordless sudo.
2. Generate a random password for the user and set it on first boot through the startup script.
3. Allow SSH to the VM only from a provided CIDR while exposing TCP/80 via an external load balancer.

After `terraform apply`, retrieve the generated credentials with:

```bash
terraform output ssh_user
terraform output -raw ssh_password
```

Use the reported username and password to connect through the private network while port 80 remains publicly accessible through the load balancer.

> **Where is the password stored?** When Terraform runs from the `examples/` directory with the default local backend, the generated password is written to the Terraform state file on disk (for example `examples/terraform.tfstate`). That file sits alongside your configuration in the same filesystem where you execute Terraform, so secure it appropriately (restrict permissions, encrypt it at rest, or move the state to a remote backend) because anyone with read access to the state can extract the password. The `terraform output -raw ssh_password` command above is simply a convenient way to display the same secret contained in the state.

## Contributing

If you encounter issues or want to propose improvements to the modules, open an *issue* or submit a *pull request*. Contributions are welcome!

## License

This project is distributed under the MIT license. See [LICENSE](https://github.com/simonevernile/repo/blob/main/LICENSE) for details.
