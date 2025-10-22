# GCP Internal Load Balancer Module

[[_TOC_]]

## Resource Schema
The module provisions a regional internal TCP/UDP load balancer backed by a regional backend service. Managed resources include:

- A reserved internal IP address.
- A regional backend service pointing to the provided zonal instance group.
- TCP health check used by the backend service.
- One forwarding rule per TCP or UDP port.

## Notes
Prerequisites:

- The network and subnetwork must exist in the target region.
- `backend_instance_group_zonal` must reference an existing zonal instance group capable of serving the requested ports.
- Firewall rules must allow health check probes from Google.

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
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix applied to created resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region where the load balancer is deployed. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input_network) | Network self link or name. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input_subnetwork) | Subnetwork self link or name. | `string` | n/a | yes |
| <a name="input_address"></a> [address](#input_address) | Optional predefined internal IP address. | `string` | `null` | no |
| <a name="input_tcp_ports"></a> [tcp_ports](#input_tcp_ports) | TCP ports exposed by the service (string values). | `list(string)` | `[]` | no |
| <a name="input_udp_ports"></a> [udp_ports](#input_udp_ports) | UDP ports exposed by the service (string values). | `list(string)` | `[]` | no |
| <a name="input_backend_instance_group_zonal"></a> [backend_instance_group_zonal](#input_backend_instance_group_zonal) | Self link of the backend zonal instance group. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input_labels) | Labels applied to supported resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_ip"></a> [internal_ip](#output_internal_ip) | Reserved internal IP address. |
| <a name="output_tcp_forwarding_rules"></a> [tcp_forwarding_rules](#output_tcp_forwarding_rules) | Names of created TCP forwarding rules. |
| <a name="output_udp_forwarding_rules"></a> [udp_forwarding_rules](#output_udp_forwarding_rules) | Names of created UDP forwarding rules. |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ilb_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_health_check.ilb_hc_tcp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_region_backend_service.ilb_bes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_forwarding_rule.ilb_tcp_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.ilb_udp_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |

## Usage
```hcl
module "lb_internal" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_internal?ref=main"
  project_id = var.project_id
  name_prefix = "internal-services"
  region      = "europe-west1"
  network     = "default"
  subnetwork  = "default"
  backend_instance_group_zonal = "projects/${var.project_id}/zones/europe-west1-b/instanceGroups/services-group"
  tcp_ports   = ["8080"]
}
```

## Alternate Usage
<details>
<summary>Expose both TCP and UDP ports.</summary>

```hcl
module "lb_internal_multi" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_internal?ref=main"
  project_id = var.project_id
  name_prefix = "internal-services"
  region      = "europe-west1"
  network     = "default"
  subnetwork  = "default"
  backend_instance_group_zonal = "projects/${var.project_id}/zones/europe-west1-b/instanceGroups/services-group"
  tcp_ports   = ["8080"]
  udp_ports   = ["53"]
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
