# Terraform GCP Modules

Reusable Terraform modules for provisioning resources on Google Cloud Platform (GCP). Each module targets a specific resource type and ships with dedicated documentation covering variables, outputs, and usage examples.

## Modules Overview

| Module | Description | Required variables | Key optional variables | Documentation |
| --- | --- | --- | --- | --- |
| **VM** | Creates a Compute Engine instance with a dedicated boot disk. | `project_id`, `vm_name`, `disk_name`, `image`, `subnetwork` | `region`, `zone`, `machine_type`, `disk_size`, `disk_type`, `network`, `tags` | [VM documentation](catalogo/gcp/vm/README.md) |
| **Firewall** | Configures firewall rules for public and private traffic to GCP resources. | `network`, `target_tags`, `local_range` | `ssh_tags`, `allow_http`, `allow_https` | [Firewall documentation](catalogo/gcp/firewall/README.md) |
| **Load Balancer** | Wraps the external and internal load balancer modules to build multiple LBs from a single list. | `project_id`, `load_balancers[*].name_prefix`, `load_balancers[*].type`, `load_balancers[*].region` | `load_balancers[*].network`, `subnetwork`, `address`, `tcp_ports`, `udp_ports`, `target_pool_instances`, `backend_ig`, `labels`, `enabled` | [Load Balancer documentation](catalogo/gcp/load_balancer/README.md) |

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
  source       = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id   = var.project_id
  vm_name      = "my-vm"
  disk_name    = "my-vm-boot"
  image        = "projects/debian-cloud/global/images/family/debian-12"
  subnetwork   = "default"
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

The [examples/main.tf](examples/main.tf) configuration composes the modules to:

1. Provision a Compute Engine VM and configure a dedicated `Implementazione` user with passwordless sudo.
2. Generate an SSH key pair that is automatically authorized on the instance.
3. Allow SSH to the VM only from a provided CIDR while exposing TCP/80 via an external load balancer.

After `terraform apply`, retrieve the generated credentials with:

```bash
terraform output -raw ssh_private_key_pem > implementazione.pem
chmod 600 implementazione.pem
terraform output ssh_user
```

Use the saved private key together with the reported username to connect through the private network while port 80 remains publicly accessible through the load balancer.

> **Where is the private key stored?** When Terraform runs from the `examples/` directory with the default local backend, the generated key pair is written to the Terraform state file on disk (for example `examples/terraform.tfstate`). That file sits alongside your configuration in the same filesystem where you execute Terraform, so secure it appropriately (restrict permissions, encrypt it at rest, or move the state to a remote backend) because anyone with read access to the state can extract the private key. The `terraform output -raw ssh_private_key_pem` command above is simply a convenient way to export the same key material to a dedicated file that you control.

## Contributing

If you encounter issues or want to propose improvements to the modules, open an *issue* or submit a *pull request*. Contributions are welcome!

## License

This project is distributed under the MIT license. See [LICENSE](LICENSE) for details.
