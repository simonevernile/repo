# Terraform GCP Modules

Reusable Terraform modules for provisioning resources on Google Cloud Platform (GCP). Each module targets a specific resource type and ships with dedicated documentation covering variables, outputs, and usage examples.

All modules require **Terraform >= 1.5.0** and the **`hashicorp/google` provider 6.x**. A few modules (Cloud SQL) also use `hashicorp/random` to generate strong passwords on demand.

## Modules Overview

| Module | Description | Key features |
| --- | --- | --- |
| **VM** (`catalogo/gcp/vm`) | Compute Engine instance with boot disk and optional data disks. | Shielded VM, OS Login, custom service account, CMEK, Spot/preemptible scheduling, deletion protection, labels, optional public IP. |
| **Firewall** (`catalogo/gcp/firewall`) | Opinionated VPC firewall rules + arbitrary custom rules. | Configurable rule prefix, IAP SSH range, health-check ranges, VPC flow logging, priority, disabled toggle, free-form `custom_rules` list. |
| **Cloud SQL MySQL** (`catalogo/gcp/mysql`) | MySQL 8 Cloud SQL instance. | Backups + binary-log retention, maintenance window, query insights, private IP, `database_flags`, additional users, optional `random_password` generation, label support. |
| **Cloud SQL PostgreSQL** (`catalogo/gcp/postgres`) | PostgreSQL 16 Cloud SQL instance. | PITR backups, maintenance window, query insights, private IP, `database_flags`, additional users, optional `random_password` generation, label support. |
| **Memorystore Redis** (`catalogo/gcp/redis`) | Memorystore Redis. | `redis_version`, transit encryption, read replicas (`STANDARD_HA`), maintenance window, RDB persistence, custom redis configs. |
| **Cloud Run** (`catalogo/gcp/cloud_run`) | Cloud Run **v2** service. | Min/max scaling, request timeout & concurrency, VPC connector, Secret Manager-backed env vars, startup/liveness probes, ingress controls, IAM invokers. |
| **Load Balancer (wrapper)** (`catalogo/gcp/load_balancer`) | Wraps the external/internal LB modules to build many LBs from a list. | TCP/UDP forwarding, labels, enable/disable per entry. |
| **GCS Bucket** (`catalogo/gcp/gcs_bucket`) | Cloud Storage bucket. | Uniform bucket-level access, public-access prevention, versioning, lifecycle rules, retention policy, CMEK, CORS, IAM bindings. |
| **Service Account** (`catalogo/gcp/service_account`) | IAM service account. | Project-level role bindings, impersonator list (`roles/iam.serviceAccountTokenCreator`), optional JSON key. |
| **Pub/Sub Topic + Subscriptions** (`catalogo/gcp/pubsub`) | Pub/Sub topic and a list of subscriptions. | CMEK, message retention, persistence regions, dead-letter, push subscriptions with OIDC, schema settings, publisher IAM. |
| **VPC Network** (`catalogo/gcp/network`) | *NEW* `google_compute_network` (the GCP equivalent of an Azure vnet). | Custom-mode VPC, regional/global routing, MTU, optional removal of the default 0.0.0.0/0 route, optional explicit egress route, Private Service Access peering for Cloud SQL/Memorystore. |
| **Subnetworks** (`catalogo/gcp/subnet`) | *NEW* One or more `google_compute_subnetwork` from a list. | Per-subnet region override, Private Google Access, secondary ranges (GKE pods/services), VPC flow logs, IPv4/IPv6 stack, `purpose`/`role` for proxy-only or PSC subnets. |
| **Firewall Rules** (`catalogo/gcp/firewall_rules`) | *NEW* Generic, list-driven firewall rules (no opinionated SSH/HTTP defaults). | INGRESS/EGRESS, ALLOW/DENY, source/target tags or service accounts, `destination_ranges`, priority, disabled toggle, optional logging. |
| **Instance Group** (`catalogo/gcp/instance_group`) | *NEW* Unmanaged zonal `google_compute_instance_group`. | Members from a list of self-links, named ports — designed as the backend group of an internal/network LB. |

## Quickstart

1. **Clone the repository**
   ```bash
   git clone https://github.com/simonevernile/repo.git
   cd repo
   ```
2. **Configure variables** via `*.tfvars` or directly in module blocks.
3. **Initialize Terraform**
   ```bash
   terraform -chdir=examples init
   ```
4. **Plan and apply**
   ```bash
   terraform -chdir=examples plan
   terraform -chdir=examples apply
   ```

## Usage Examples

### VM Module — hardened defaults

```hcl
module "vm" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/vm?ref=main"
  project_id = var.project_id
  vm_name    = "app-vm"
  network    = "default"
  subnetwork = "default"

  boot_disk = {
    name = "app-vm-boot"
    size = 30
    type = "pd-balanced"
  }

  boot_disk_image = "projects/debian-cloud/global/images/family/debian-12"

  labels         = { app = "frontend", env = "prod" }
  enable_oslogin = true

  shielded_vm = {
    secure_boot          = true
    vtpm                 = true
    integrity_monitoring = true
  }

  service_account = {
    email = google_service_account.runtime.email
  }
}
```

### Firewall Module — IAP SSH + custom rules

```hcl
module "firewall" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall?ref=main"
  project_id = var.project_id

  name_prefix         = "app"
  network             = "default"
  target_tags         = ["frontend"]
  ssh_tags            = ["frontend"]
  local_range         = ["10.0.0.0/8"]
  allow_iap_ssh       = true
  allow_https         = true
  allow_health_checks = true
  enable_logging      = true

  custom_rules = [
    {
      name        = "allow-icmp"
      direction   = "INGRESS"
      action      = "ALLOW"
      target_tags = ["frontend"]
      source_ranges = ["10.0.0.0/8"]
      rules = [{ protocol = "icmp", ports = [] }]
    }
  ]
}
```

### Cloud SQL PostgreSQL — private IP + auto-generated password

```hcl
module "postgres" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/postgres?ref=main"
  project_id = var.project_id

  instance_name     = "app-pg"
  database_version  = "POSTGRES_16"
  tier              = "db-custom-2-7680"
  availability_type = "REGIONAL"

  private_network   = google_compute_network.vpc.id
  enable_public_ip  = false

  generate_password = true
  database_name     = "app"

  database_flags = {
    "max_connections" = "200"
    "log_min_duration_statement" = "500"
  }

  backup = {
    enabled                        = true
    point_in_time_recovery_enabled = true
    start_time                     = "03:00"
    retained_backups               = 14
  }
}
```

### Cloud Run v2 with Secret Manager + scaling

```hcl
module "api" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/cloud_run?ref=main"
  project_id = var.project_id

  service_name = "api"
  image        = "europe-docker.pkg.dev/${var.project_id}/apps/api:latest"

  scaling = {
    min_instances = 1
    max_instances = 20
  }

  resource_limits = {
    cpu    = "2"
    memory = "1Gi"
  }

  env_vars = {
    LOG_LEVEL = "info"
  }

  secret_env_vars = [
    { name = "DB_PASSWORD", secret = "projects/${var.project_id}/secrets/db-password" }
  ]

  liveness_probe = {
    port = 8080
    path = "/healthz"
  }

  allow_unauthenticated = false
  invoker_members       = ["serviceAccount:caller@${var.project_id}.iam.gserviceaccount.com"]
}
```

### GCS bucket with lifecycle and CMEK

```hcl
module "artifacts" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/gcs_bucket?ref=main"
  project_id = var.project_id

  name                        = "${var.project_id}-artifacts"
  location                    = "EU"
  versioning                  = true
  uniform_bucket_level_access = true
  kms_key_name                = google_kms_crypto_key.bucket.id

  lifecycle_rules = [
    { action = { type = "SetStorageClass", storage_class = "NEARLINE" }, condition = { age = "30" } },
    { action = { type = "Delete" }, condition = { age = "365" } },
  ]
}
```

### VPC + Subnets + Firewall Rules + Instance Group

```hcl
module "vpc" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/network?ref=main"
  project_id = var.project_id

  name                          = "core-vpc"
  routing_mode                  = "REGIONAL"
  enable_private_service_access = true # for Cloud SQL/Memorystore private IP
}

module "subnets" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/subnet?ref=main"
  project_id = var.project_id
  network    = module.vpc.self_link
  region     = "europe-west1"

  subnets = [
    {
      name          = "app-ew1"
      ip_cidr_range = "10.10.0.0/24"
      flow_logs     = {} # default sampling
    },
    {
      name          = "gke-ew1"
      ip_cidr_range = "10.20.0.0/22"
      secondary_ip_ranges = [
        { range_name = "pods",     ip_cidr_range = "10.40.0.0/14" },
        { range_name = "services", ip_cidr_range = "10.44.0.0/20" },
      ]
    },
  ]
}

module "fw" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall_rules?ref=main"
  project_id = var.project_id
  network    = module.vpc.self_link

  rules = [
    {
      name          = "allow-internal-tcp"
      direction     = "INGRESS"
      action        = "ALLOW"
      priority      = 1000
      source_ranges = ["10.0.0.0/8"]
      target_tags   = ["app"]
      rules         = [{ protocol = "tcp", ports = ["80", "443"] }]
    },
    {
      name               = "deny-egress-public"
      direction          = "EGRESS"
      action             = "DENY"
      priority           = 100
      destination_ranges = ["0.0.0.0/0"]
      target_tags        = ["restricted"]
      rules              = [{ protocol = "all" }]
    },
  ]
}

module "backend_ig" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/instance_group?ref=main"
  project_id = var.project_id

  name = "app-ig-ew1b"
  zone = "europe-west1-b"

  instances = [module.vm.instance_self_link]

  named_ports = [
    { name = "http",  port = 80 },
    { name = "https", port = 443 },
  ]
}

# Plug it as backend of the internal LB:
module "ilb" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [{
    name_prefix = "app"
    type        = "internal"
    region      = "europe-west1"
    network     = module.vpc.self_link
    subnetwork  = module.subnets.self_links["app-ew1"]
    tcp_ports   = [80]
    backend_ig  = module.backend_ig.self_link
  }]
}
```

### End-to-end example

The [examples/main.tf](examples/main.tf) configuration composes the modules to:

1. Create a dedicated runtime service account with logging/monitoring roles.
2. Provision a hardened Compute Engine VM (Shielded VM, attached SA, Rocky Linux 9 boot image) running [examples/startup.sh](examples/startup.sh), which sets up the `Implementazione` and `weblogic` service users, enables SSH password auth, installs `nfs-utils`/`unzip` and mounts the POC NFS share.
3. Open SSH only from a configurable CIDR (plus IAP if requested) and HTTP through an external load balancer.
4. Provision a versioned GCS bucket with lifecycle rules.

After `terraform apply` the VM exposes the `Implementazione` service user (credentials managed inside `startup.sh`, not in Terraform state).

## Contributing

Open an issue or submit a pull request — contributions are welcome.

## License

Distributed under the MIT license. See [LICENSE](https://github.com/simonevernile/repo/blob/main/LICENSE) for details.
