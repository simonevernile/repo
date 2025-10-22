# GCP Firewall Module

[[_TOC_]]

## Resource Schema
The module provisions network firewall rules to secure SSH access and optionally expose HTTP/HTTPS to tagged instances. Managed resources include:

- `google_compute_firewall.allow_local_ssh` allowing SSH from the provided CIDR ranges to hosts tagged with `ssh_tags`.
- Optional `google_compute_firewall.allow_public_http` and `google_compute_firewall.allow_public_https` rules to expose web traffic to instances tagged with `target_tags`.

## Notes
Prerequisites:

- A GCP project with the **Compute Engine** API enabled.
- A VPC network matching the `network` variable.
- Compute Engine instances with tags matching `target_tags` (HTTP/HTTPS) or `ssh_tags` (SSH).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement_google) | Unpinned |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | Unpinned (tested with >= 5.0) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network"></a> [network](#input_network) | Name or self link of the network where firewall rules apply. | `string` | n/a | yes |
| <a name="input_target_tags"></a> [target_tags](#input_target_tags) | Tags applied to instances receiving HTTP/HTTPS rules. | `list(string)` | n/a | yes |
| <a name="input_local_range"></a> [local_range](#input_local_range) | CIDR ranges allowed to connect via SSH. | `list(string)` | n/a | yes |
| <a name="input_ssh_tags"></a> [ssh_tags](#input_ssh_tags) | Tags that receive the SSH rule. | `list(string)` | `[]` | no |
| <a name="input_allow_http"></a> [allow_http](#input_allow_http) | Enable ingress rule for HTTP traffic on port 80. | `bool` | `false` | no |
| <a name="input_allow_https"></a> [allow_https](#input_allow_https) | Enable ingress rule for HTTPS traffic on port 443. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_http_firewall"></a> [public_http_firewall](#output_public_http_firewall) | ID of the optional HTTP firewall rule (or `null`). |
| <a name="output_local_ssh_firewall"></a> [local_ssh_firewall](#output_local_ssh_firewall) | ID of the SSH firewall rule. |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_local_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_public_http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_public_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Usage
```hcl
module "firewall" {
  source      = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/firewall?ref=main"
  network     = "default"
  target_tags = ["web"]
  local_range = ["10.128.0.0/20"]
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
  local_range = ["10.128.0.0/20"]
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
