# Load Balancer Module Documentation

## Overview
This module provisions a public and private load balancer in GCP, allowing traffic to be distributed across backend services. You can configure forwarding rules and target pools for both the public and private load balancers.

## Input Variables
| Nome         | Tipo     | Default   | Descrizione |
|--------------|----------|-----------|-------------|
| `region`     | `string` | _Nessuno_ | Regione in cui verrà creato il load balancer. |
| `network`    | `string` | `default` | Rete a cui è connesso il load balancer. |
| `allow_http` | `bool`   | `true`    | Abilitazione del traffico HTTP (porta 80). |
| `allow_https` | `bool`   | `true`    | Abilitazione del traffico HTTPS (porta 443). |

## Output Values
| Nome        | Tipo     | Descrizione |
|-------------|----------|-------------|
| `public_ip` | `string` | Indirizzo IP pubblico del load balancer. |
| `private_ip` | `string` | Indirizzo IP privato del load balancer. |

## Usage Example
```hcl
module "load_balancer" {
  source = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load%20balancer?ref=main"
  region = "us-central1"
}
```

## Diagramma Testuale
```
[Client] -> [Forwarding Rule] -> [Backend Service]
                |
                -> [Private Forwarding Rule] -> [Internal Backend]
```

## Note
- Personalizzare i backend in base alle istanze o ai gruppi di istanze che devono ricevere il traffico.
- Verificare che le porte necessarie siano aperte nelle regole firewall associate.
