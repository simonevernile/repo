# GCP External Load Balancer Module

[[_TOC_]]

## Resource Schema
The module provisions an external HTTP(S) load balancer backed by managed instance groups. Core components include:

- Global forwarding rules and target HTTP proxies for each enabled port.
- URL map, backend service, and health check per load balancer instance.
- Optional static external IP address when `address` is provided.

## Notes
Prerequisites:

- Managed instance group matching `backend_ig` and located in `backend_zone`.
- Firewall rules allowing health check probes from Google.
- Optional reserved IP address if you plan to reuse an existing static IP.

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
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix applied to all resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region hosting the backend instance group. | `string` | n/a | yes |
| <a name="input_tcp_ports"></a> [tcp_ports](#input_tcp_ports) | List of TCP ports exposed by the load balancer. | `list(number)` | `[]` | no |
| <a name="input_backend_zone"></a> [backend_zone](#input_backend_zone) | Zone of the backend instance group. | `string` | n/a | yes |
| <a name="input_backend_ig"></a> [backend_ig](#input_backend_ig) | Name of the managed instance group serving traffic. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input_labels) | Labels applied to load balancer resources. | `map(string)` | `{}` | no |
| <a name="input_address"></a> [address](#input_address) | Self link of an existing static IP to attach. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_forwarding_rules"></a> [forwarding_rules](#output_forwarding_rules) | Map of forwarding rule names keyed by port. |
| <a name="output_ip_address"></a> [ip_address](#output_ip_address) | Assigned external IP address. |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module_metadata) | git::https://gitlab.alm.poste.it/guidelines/hybridcloud/iac-modules/terraform/terraform-module-metadata.git | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.lb_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_backend_service.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_compute_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_health_check.health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_forwarding_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |

## Usage
```hcl
module "lb_external" {
  source       = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_external?ref=main"
  project_id   = var.project_id
  name_prefix  = "app"
  region       = "europe-west1"
  backend_zone = "europe-west1-b"
  backend_ig   = "app-group"
  tcp_ports    = [80, 443]
}
```

## Alternate Usage
<details>
<summary>Attach an existing static IP.</summary>

```hcl
module "lb_external_static" {
  source       = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_external?ref=main"
  project_id   = var.project_id
  name_prefix  = "app"
  region       = "europe-west1"
  backend_zone = "europe-west1-b"
  backend_ig   = "app-group"
  tcp_ports    = [443]
  address      = google_compute_address.static_ip.self_link
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
