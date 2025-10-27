# Combined VM and Load Balancer Example

This example composes the catalog modules to provision a Compute Engine VM, the
firewall rules that expose SSH locally, and an external TCP load balancer.

## What gets created

* A Debian-based VM (`catalogo/gcp/vm`) with custom metadata that uploads an SSH
  public key generated at deploy time.
* Firewall rules (`catalogo/gcp/firewall`) that allow:
  * TCP/22 from the CIDR provided through `var.ssh_source_cidr` (for example a
    single `/32` representing your jump host).
  * Optional public HTTP/HTTPS access when `allow_http`/`allow_https` are set.
* An external network load balancer (`catalogo/gcp/load_balancer`) that listens
  on TCP ports (80 by default) and forwards traffic to the VM via its self link.

The modules are wired together in [`main.tf`](https://github.com/simonevernile/repo/blob/main/examples/main.tf). The VM is tagged with
`restricted-ssh` so that only the SSH firewall rule matches it, and the
load balancer consumes the instance self link as part of the target pool.

## Usage

```bash
cd examples
terraform init
export TF_VAR_project_id="<your-project>"
export TF_VAR_region="<your-region>"
export TF_VAR_zone="<your-zone>"
export TF_VAR_network="default"
export TF_VAR_subnetwork="default"
export TF_VAR_ssh_source_cidr="198.51.100.10/32"
terraform validate
# terraform plan    # requires Google Cloud credentials
```

`terraform validate` succeeds with placeholder values, as shown in the session
transcript stored in this repository.
