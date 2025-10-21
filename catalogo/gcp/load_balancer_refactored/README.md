# GCP Load Balancer (External TCP/UDP NLB + Internal TCP/UDP ILB)

Modulo Terraform opinionato che crea **due** bilanciatori:
- **External Network Load Balancer** (TCP/UDP) con Target Pool e una regola per **ogni porta** definita.
- **Internal TCP/UDP Load Balancer** regionale con **Region Backend Service** e forwarding rule per **ogni porta** definita.

## Variabili principali

- `project_id`, `region`
- `network`, `subnetwork` (per l'ILB)
- `external_tcp_ports`, `external_udp_ports`
- `internal_tcp_ports`, `internal_udp_ports`
- `external_target_pool_instances` (self_link delle VM per l'NLB)
- `ilb_backend_instance_group_zonal` (self_link IG esistente) **oppure** `ilb_backend_zone` per creare un IG vuoto placeholder
- `name_prefix`, `labels`

## Esempio d'uso

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

module "lb" {
  source  = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/load_balancer_refactored?ref=main"

  project_id = var.project_id
  region     = var.region
  network    = "default"
  subnetwork = "default"

  external_tcp_ports = [80, 443]
  external_udp_ports = [53]

  internal_tcp_ports = [8080, 8443]
  internal_udp_ports = []

  // opzionale: allega VM al target pool esterno
  external_target_pool_instances = []

  // opzionale: backend IG per ILB; se omesso, ne crea uno placeholder vuoto
  ilb_backend_zone = "europe-west1-b"

  name_prefix = "myapp"
  labels = {
    app = "myapp"
    env = "dev"
  }
}
```

## Note

- Per l'**External NLB** Google richiede Target Pool: le health check sono di tipo TCP (porta 80 di default). Cambia la porta del check se necessario.
- Per l'**Internal LB** viene creato un Region Backend Service con health check TCP e forwarding rule con `ports` per singola porta. Se hai bisogno di più backends/zones, passa un IG esistente con `ilb_backend_instance_group_zonal`.
