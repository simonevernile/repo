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
| **GCS Bucket** (`catalogo/gcp/gcs_bucket`) | *NEW* Cloud Storage bucket. | Uniform bucket-level access, public-access prevention, versioning, lifecycle rules, retention policy, CMEK, CORS, IAM bindings. |
| **Service Account** (`catalogo/gcp/service_account`) | *NEW* IAM service account. | Project-level role bindings, impersonator list (`roles/iam.serviceAccountTokenCreator`), optional JSON key. |
| **Pub/Sub Topic + Subscriptions** (`catalogo/gcp/pubsub`) | *NEW* Pub/Sub topic and a list of subscriptions. | CMEK, message retention, persistence regions, dead-letter, push subscriptions with OIDC, schema settings, publisher IAM. |

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
