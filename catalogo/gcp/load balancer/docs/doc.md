
---

### 3. **Documentazione del Modulo Load Balancer (`modules/load_balancer/docs/README.md`)** - Con Obbligatori e Facoltativi

```markdown
# Load Balancer Module Documentation

## Overview
This module provisions a public and private load balancer in GCP, allowing traffic to be distributed across backend services. You can configure forwarding rules and target pools for both the public and private load balancers.

## Input Variables

### **Required Variables**
These variables **must** be provided to use this module.

#### `region`
- **Description**: The region where the load balancer will be created.
- **Type**: `string`

#### `network`
- **Description**: The network to which the load balancer is connected.
- **Type**: `string`
- **Default**: `default`

### **Optional Variables**
These variables are **optional** and can be left unset.

#### `allow_http`
- **Description**: Flag to indicate whether to allow HTTP traffic (port 80) on the load balancer.
- **Type**: `bool`
- **Default**: `true`

#### `allow_https`
- **Description**: Flag to indicate whether to allow HTTPS traffic (port 443) on the load balancer.
- **Type**: `bool`
- **Default**: `true`

## Output Values
### `public_ip`
- **Description**: The public IP address of the load balancer.
- **Type**: `string`

### `private_ip`
- **Description**: The private IP address of the load balancer.
- **Type**: `string`

## Usage Example

```hcl
module "load_balancer" {
  source   = "./modules/load_balancer"
  region   = "us-central1"
}
