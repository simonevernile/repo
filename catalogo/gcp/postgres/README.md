# Cloud SQL PostgreSQL Module

This module provisions a PostgreSQL Cloud SQL instance with configurable compute tier, storage, availability, optional public IP, and optional database/user setup.

## Usage

```hcl
module "postgres" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/postgres?ref=main"
  project_id = var.project_id

  instance_name = "app-db"
  tier          = "db-f1-micro"

  # Optional settings
  database_version    = "POSTGRES_15"
  availability_type   = "REGIONAL"
  disk_size           = 50
  disk_type           = "PD_SSD"
  deletion_protection = true
  enable_public_ip    = false
  postgres_password   = var.postgres_password
  database_name       = "app"
}
```

## Variables

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| `project_id` | GCP project ID | string | n/a |
| `instance_name` | Name of the Cloud SQL instance | string | n/a |
| `region` | Region where the instance is created | string | `"europe-west1"` |
| `database_version` | Cloud SQL database engine version | string | `"POSTGRES_15"` |
| `tier` | Machine type for the instance (e.g. db-f1-micro, db-custom-1-3840) | string | `"db-f1-micro"` |
| `disk_size` | Size of the data disk in GB | number | `20` |
| `disk_type` | Type of the data disk (PD_SSD or PD_HDD) | string | `"PD_SSD"` |
| `availability_type` | Availability type for the instance (ZONAL or REGIONAL) | string | `"ZONAL"` |
| `deletion_protection` | When true, prevents Terraform from destroying the instance | bool | `true` |
| `postgres_password` | Password for the postgres user; when null no password is set by Terraform | string | `null` |
| `database_name` | Optional database to create within the instance | string | `null` |
| `enable_public_ip` | Enable the public IPv4 address for the instance | bool | `false` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `connection_name` | Connection name used by clients to connect to the instance |
| `self_link` | Self link of the Cloud SQL instance |
| `database` | Name of the database created when `database_name` is provided |
