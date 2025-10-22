# GCP Internal Load Balancer Module

[[_TOC_]]

## Resource Schema
The module provisions a regional internal TCP/UDP load balancer pointing to a backend instance group. Managed components include:

- Forwarding rule with reserved internal IP.
- Backend service associated with the provided instance group.
- Health check targeting backend instances.

## Notes
Prerequisites:

- Subnetwork in the specified region where the internal IP will be allocated.
- Instance group referenced by `backend_ig` must exist and expose the desired ports.
- Firewall rules allowing probe traffic from Google health checks.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | Unpinned (tested with >= 4.0.0) |

## Resource Schema
Il modulo crea un Internal TCP/UDP Load Balancer regionale con backend service e forwarding rule dedicate. Le risorse gestite sono:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project_id](#input_project_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix) | Prefix applied to created resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region where the load balancer is deployed. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input_network) | Name or self link of the host network. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input_subnetwork) | Name or self link of the subnetwork for the forwarding rule. | `string` | n/a | yes |
| <a name="input_address"></a> [address](#input_address) | Optional existing internal IP to reserve. | `string` | `null` | no |
| <a name="input_tcp_ports"></a> [tcp_ports](#input_tcp_ports) | TCP ports exposed by the service. | `list(number)` | `[]` | no |
| <a name="input_udp_ports"></a> [udp_ports](#input_udp_ports) | UDP ports exposed by the service. | `list(number)` | `[]` | no |
| <a name="input_backend_instance_group_zonal"></a> [backend_instance_group_zonal] | Self-link of the backend zonal instance group | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input_labels) | Labels applied to load balancer resources. | `map(string)` | `{}` | no |

## Notes
Prerequisiti:

| Name | Description |
|------|-------------|
| <a name="output_forwarding_rule"></a> [forwarding_rule](#output_forwarding_rule) | Name of the forwarding rule created for the service. |
| <a name="output_ip_address"></a> [ip_address](#output_ip_address) | Assigned internal IP address. |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module_metadata) | git::https://gitlab.alm.poste.it/guidelines/hybridcloud/iac-modules/terraform/terraform-module-metadata.git | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.internal_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_health_check.health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_backend_service.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_forwarding_rule.forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |

## Usage
```hcl
module "lb_internal" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_internal?ref=main"
  project_id  = var.project_id
  name_prefix = "internal-services"
  region      = "europe-west1"
  network     = "default"
  subnetwork  = "default"
  backend_instance_group_zonal  = "services-group"
  tcp_ports   = [8080]
}
```

## Alternate Usage
<details>
<summary>Expose both TCP and UDP ports.</summary>

```hcl
module "lb_internal_multi" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_internal?ref=main"
  project_id  = var.project_id
  name_prefix = "internal-services"
  region      = "europe-west1"
  network     = "default"
  subnetwork  = "default"
  backend_instance_group_zonal  = "services-group"
  tcp_ports   = [8080]
  udp_ports   = [53]
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