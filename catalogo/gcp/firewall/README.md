# GCP Firewall Module

[[_TOC_]]

## Resource Schema
The module provisions firewall rules to secure SSH access and optionally enable HTTP/HTTPS ingress. Managed resources include:

- SSH allow rule restricted to the `local_range` CIDR and `ssh_tags` targets.
- Optional rules for HTTP (80/tcp) and HTTPS (443/tcp) controlled by input variables.
- Tag-based association to the Compute Engine instances listed through `target_tags`.

Common resources such as networks or subnets must be managed by other modules.

## Notes
Prerequisites:

- A GCP project with the **Compute Engine** API enabled.
- A VPC network matching the `network` variable (name or self link).
- Compute Engine instances labeled with the `target_tags` passed to this module.

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
| <a name="input_network"></a> [network](#input_network) | Name or self link of the network where firewall rules apply. | `string` | n/a | yes |
| <a name="input_target_tags"></a> [target_tags](#input_target_tags) | List of tags applied to instances to receive the rules. | `list(string)` | n/a | yes |
| <a name="input_local_range"></a> [local_range](#input_local_range) | CIDR block allowed to SSH into the targets. | `string` | n/a | yes |
| <a name="input_ssh_tags"></a> [ssh_tags](#input_ssh_tags) | Additional target tags receiving the SSH rule. | `list(string)` | n/a | yes |
| <a name="input_allow_http"></a> [allow_http](#input_allow_http) | Enable ingress rule for HTTP traffic on port 80. | `bool` | `false` | no |
| <a name="input_allow_https"></a> [allow_https](#input_allow_https) | Enable ingress rule for HTTPS traffic on port 443. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_rules"></a> [firewall_rules](#output_firewall_rules) | Map of created firewall rule names keyed by purpose. |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module_metadata) | git::https://gitlab.alm.poste.it/guidelines/hybridcloud/iac-modules/terraform/terraform-module-metadata.git | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Usage
```hcl
module "firewall" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall?ref=main"
  network     = "default"
  target_tags = ["web"]
  local_range = "10.128.0.0/20"
  ssh_tags    = ["ssh"]
}
```

## Alternate Usage
<details>
<summary>Enable HTTP/HTTPS ingress for web workloads.</summary>

```hcl
module "firewall_web" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall?ref=main"
  network     = "default"
  target_tags = ["web"]
  local_range = "10.128.0.0/20"
  ssh_tags    = ["ssh"]
  allow_http  = true
  allow_https = true
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
