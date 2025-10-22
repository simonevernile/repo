# Load Balancer Module Documentation

## Overview
Il modulo wrapper `catalogo/gcp/load_balancer` permette di creare più load balancer (esterni ed interni) su GCP partendo da una singola lista di configurazioni. Ogni elemento della lista indica se creare un bilanciatore **external** (Network Load Balancer con target pool) o **internal** (Internal TCP/UDP LB con backend service regionale).

## Input Variables
| Nome | Tipo | Default | Descrizione |
|------|------|---------|-------------|
| `project_id` | `string` | _Nessuno_ | ID del progetto GCP su cui creare le risorse. |
| `load_balancers` | `list(object({ ... }))` | `[]` | Lista di load balancer da creare. Ogni oggetto richiede `name_prefix`, `type`, `region` e opzionalmente `network`, `subnetwork`, `address`, `tcp_ports`, `udp_ports`, `target_pool_instances`, `backend_ig`, `labels`, `enabled`. |

## Output Values
| Nome | Tipo | Descrizione |
|------|------|-------------|
| `results` | `map(object)` | Mappa indicizzata per elemento della lista con IP (`external_ip`/`internal_ip`) e forwarding rules (`tcp_forwarding_rules`, `udp_forwarding_rules`) restituiti dai moduli figli. |

## Usage Example
```hcl
module "load_balancers" {
  source     = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer?ref=main"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "api"
      type        = "external"
      region      = "europe-west1"
      tcp_ports   = [80, 443]
    },
    {
      name_prefix = "internal"
      type        = "internal"
      region      = "europe-west1"
      network     = "default"
      subnetwork  = "default"
      tcp_ports   = [8080]
    }
  ]
}
```

## Diagramma Testuale
```
[List configurazioni]
       |
       +--> LB esterno -> target pool -> istanze
       |
       +--> LB interno -> backend service -> instance group
```

## Note
- Gli elementi con `enabled = false` vengono ignorati.
- Per i load balancer interni è necessario che rete e subnet esistano nella regione scelta.
- Assicurarsi che le regole firewall permettano i controlli di salute e il traffico utente sulle porte specificate.
