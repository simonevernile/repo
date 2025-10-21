# GCP Load Balancer Wrapper Module

[[_TOC_]]

## Resource Schema
The module orchestrates the creation of multiple external and internal load balancers using a single list of descriptors. It leverages the child modules found in `catalogo/gcp/load_balancer_external` and `catalogo/gcp/load_balancer_internal` depending on the `type` value. Managed resources may include:

- Global or regional forwarding rules.
- External IP addresses.
- Backend services, target pools, instance groups, and health checks.

All supporting resources (compute instances, instance groups, subnets) must be provided beforehand.

## Notes
Prerequisites:

- Enabled **Compute Engine** API on the target project.
- Existing instance groups or backend services referenced by the module inputs.
- For internal load balancers, a subnet in the specified region.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | Unpinned (tested with >= 4.0.0) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID where load balancers will be created. | `string` | n/a | yes |
| <a name="input_load_balancers"></a> [load_balancers](#input_load_balancers) | List describing each load balancer to provision. | <pre>list(object({
    name_prefix = string
    type        = string
    region      = string
    network     = optional(string)
    subnetwork  = optional(string)
    address     = optional(string)
    tcp_ports   = optional(list(number))
    udp_ports   = optional(list(number))
    backend_zone = optional(string)
    backend_ig   = optional(string)
    labels       = optional(map(string))
    enabled      = optional(bool, true)
  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_results"></a> [results](#output_results) | Aggregated outputs from each load balancer module call. |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module_metadata) | git::https://gitlab.alm.poste.it/guidelines/hybridcloud/iac-modules/terraform/terraform-module-metadata.git | v1.0.1 |
| <a name="module_lb_ext"></a> [lb_ext](#module_lb_ext) | ../load_balancer_external | n/a |
| <a name="module_lb_int"></a> [lb_int](#module_lb_int) | ../load_balancer_internal | n/a |

## Usage
```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix  = "api"
      type         = "external"
      region       = "europe-west1"
      tcp_ports    = [80, 443]
      backend_zone = "europe-west1-b"
      backend_ig   = "api-group"
    },
    {
      name_prefix = "internal-services"
      type        = "internal"
      region      = "europe-west1"
      network     = "default"
      subnetwork  = "default"
      tcp_ports   = [8080]
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
