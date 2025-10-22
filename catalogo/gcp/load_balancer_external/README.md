# GCP External Load Balancer Module

[[_TOC_]]

## Resource Schema
The module provisions a regional external TCP/UDP Network Load Balancer using a target pool. Managed components include:

- A regional static IP address.
- An HTTP health check associated with the target pool.
- A target pool populated with the provided instance self links.
- One forwarding rule per TCP or UDP port.

## Notes
Prerequisites:

- Instances referenced in `target_pool_instances` must exist in the selected region/zone.
- Firewall rules must allow health check probes from Google on the relevant ports.
- The Compute Engine API must be enabled on the project.

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
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix applied to all resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region hosting the load balancer. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input_labels) | Labels applied to supported resources. | `map(string)` | `{}` | no |
| <a name="input_tcp_ports"></a> [tcp_ports](#input_tcp_ports) | TCP ports exposed by the load balancer (string values). | `list(string)` | `[]` | no |
| <a name="input_udp_ports"></a> [udp_ports](#input_udp_ports) | UDP ports exposed by the load balancer (string values). | `list(string)` | `[]` | no |
| <a name="input_target_pool_instances"></a> [target_pool_instances](#input_target_pool_instances) | Instance self links attached to the target pool. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ip"></a> [external_ip](#output_external_ip) | Assigned external IP address. |
| <a name="output_tcp_forwarding_rules"></a> [tcp_forwarding_rules](#output_tcp_forwarding_rules) | Names of created TCP forwarding rules. |
| <a name="output_udp_forwarding_rules"></a> [udp_forwarding_rules](#output_udp_forwarding_rules) | Names of created UDP forwarding rules. |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ext_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_http_health_check.ext_hc_http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check) | resource |
| [google_compute_target_pool.ext_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_pool) | resource |
| [google_compute_forwarding_rule.ext_tcp_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.ext_udp_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |

## Usage
```hcl
module "lb_external" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_external?ref=main"
  project_id  = var.project_id
  name_prefix = "app"
  region      = "europe-west1"
  tcp_ports   = ["80", "443"]
  target_pool_instances = [
    "projects/${var.project_id}/zones/europe-west1-b/instances/app-01",
  ]
}
```

## Alternate Usage
<details>
<summary>Expose UDP ports in addition to TCP.</summary>

```hcl
module "lb_external_udp" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_external?ref=main"
  project_id  = var.project_id
  name_prefix = "dns"
  region      = "europe-west1"
  tcp_ports   = []
  udp_ports   = ["53"]
  target_pool_instances = [
    "projects/${var.project_id}/zones/europe-west1-b/instances/dns-01",
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
