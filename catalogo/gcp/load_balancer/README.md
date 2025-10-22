# GCP Load Balancer Wrapper Module

[[_TOC_]]

## Resource Schema
The wrapper iterates over a list of descriptors and provisions the requested load balancers by delegating to:

- [`catalogo/gcp/load_balancer_external`](../load_balancer_external) for external TCP/UDP network load balancers backed by target pools.
- [`catalogo/gcp/load_balancer_internal`](../load_balancer_internal) for regional internal TCP/UDP load balancers with regional backend services.

Each enabled entry is forwarded to the appropriate child module; disabled entries (with `enabled = false`) are skipped. Any prerequisite backends (instance groups, services, subnets) must already exist.

## Notes
Prerequisites:

- Enabled **Compute Engine** API on the target project.
- Pre-created backend resources (instance groups or target pool instances) referenced by the descriptors.
- For internal load balancers, the network and subnet must exist in the specified region.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where load balancers will be created. | `string` | n/a | yes |
| <a name="input_load_balancers"></a> [load_balancers](#input_load_balancers) | List describing each load balancer. Disabled entries (`enabled = false`) are ignored. See the [descriptor schema](#load_balancer_descriptor_schema). | `list(object({ ... }))` | `[]` | no |

> **Note:** `backend_ig` is passed to the internal module as `backend_instance_group_zonal`. The optional `backend_zone` attribute is currently ignored by the implementation.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_results"></a> [results](#output_results) | Map keyed by entry index. Each value exposes `external_ip`, `internal_ip`, `tcp_forwarding_rules`, and `udp_forwarding_rules` returned by the child modules. |

### <a name="load_balancer_descriptor_schema"></a>Load balancer descriptor schema

```hcl
{
  name_prefix          = string
  type                 = string          # "external" or "internal"
  region               = string
  network              = optional(string)
  subnetwork           = optional(string)
  address              = optional(string)
  tcp_ports            = optional(list(number))
  udp_ports            = optional(list(number))
  target_pool_instances = optional(list(string))
  backend_ig           = optional(string)
  labels               = optional(map(string))
  enabled              = optional(bool, true)
}
```

## Usage
```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix          = "api"
      type                 = "external"
      region               = "europe-west1"
      tcp_ports            = [80, 443]
      target_pool_instances = [
        "projects/${var.project_id}/zones/europe-west1-b/instances/api-01",
      ]
      labels = { app = "frontend" }
    },
    {
      name_prefix = "internal-services"
      type        = "internal"
      region      = "europe-west1"
      network     = "default"
      subnetwork  = "default"
      tcp_ports   = [8080]
      backend_ig  = "projects/${var.project_id}/zones/europe-west1-b/instanceGroups/services-group"
    }
  ]
}
```

## Alternate Usage
<details>
<summary>Disable a load balancer entry without removing it.</summary>

```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "frontend"
      type        = "external"
      region      = "europe-west1"
      tcp_ports   = [80]
      enabled     = false
    },
    {
      name_prefix = "backend"
      type        = "internal"
      region      = "europe-west1"
      network     = "default"
      subnetwork  = "default"
      tcp_ports   = [8443]
      backend_ig  = "projects/${var.project_id}/zones/europe-west1-b/instanceGroups/backend-group"
    }
  ]
}
```
</details>

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
