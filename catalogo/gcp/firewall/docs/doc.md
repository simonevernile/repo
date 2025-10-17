
---

### 2. **Documentazione del Modulo Firewall (`modules/firewall/docs/README.md`)** - Con Obbligatori e Facoltativi

```markdown
# Firewall Module Documentation

## Overview
This module creates firewall rules to control traffic to and from your GCP resources. It can be used to allow or deny traffic based on IP ranges, and allows you to specify the target tags for the firewall rules.

## Input Variables

### **Required Variables**
These variables **must** be provided to use this module.

#### `network`
- **Description**: The network where the firewall rules will be applied.
- **Type**: `string`

#### `target_tags`
- **Description**: The tags assigned to the firewall targets (e.g., `"web"`, `"ssh"`).
- **Type**: `list(string)`

#### `local_range`
- **Description**: The source IP range for the local firewall rule (e.g., `"10.128.0.0/20"`).
- **Type**: `string`

#### `ssh_tags`
- **Description**: The tags for SSH access firewall rule.
- **Type**: `list(string)`

### **Optional Variables**
These variables are **optional** and can be left unset.

#### `allow_http`
- **Description**: Flag to indicate whether to allow HTTP traffic (port 80).
- **Type**: `bool`
- **Default**: `true`

#### `allow_https`
- **Description**: Flag to indicate whether to allow HTTPS traffic (port 443).
- **Type**: `bool`
- **Default**: `true`

## Output Values
### `public_http_firewall`
- **Description**: The ID of the public HTTP firewall rule.
- **Type**: `string`

### `local_ssh_firewall`
- **Description**: The ID of the local SSH firewall rule.
- **Type**: `string`

## Usage Example

```hcl
module "firewall" {
  source    = "./modules/firewall"
  network   = "default"
  target_tags = ["web"]
  local_range = "10.128.0.0/20"
  ssh_tags   = ["ssh"]
}
