# Memorystore Redis Module

Crea un'istanza Memorystore per Redis con configurazione base di memoria, tier e autenticazione opzionale.

## Esempio di utilizzo

```hcl
module "redis" {
  source  = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/redis?ref=main"
  project_id = var.project_id
  name       = "app-redis"
  region     = "europe-west1"
  tier       = "STANDARD_HA"
  memory_size_gb = 2
  auth_enabled   = true
}
```

## Variabili

| Nome | Tipo | Default | Descrizione |
| --- | --- | --- | --- |
| `project_id` | string | n/a | ID del progetto GCP. |
| `name` | string | n/a | Nome dell'istanza Redis. |
| `region` | string | `europe-west1` | Regione in cui distribuire Redis. |
| `tier` | string | `BASIC` | Tier di disponibilità (`BASIC` o `STANDARD_HA`). |
| `memory_size_gb` | number | `1` | Dimensione della memoria in GB. |
| `auth_enabled` | bool | `false` | Abilita l'autenticazione Redis. |

## Output

| Nome | Descrizione |
| --- | --- |
| `host` | Host dell'istanza Redis. |
| `port` | Porta di connessione. |
| `auth_string` | Password generata quando l'autenticazione è attiva. |
