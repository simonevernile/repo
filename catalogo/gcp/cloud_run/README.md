# Cloud Run Module

Crea e pubblica un servizio Cloud Run a partire da un'immagine container, con gestione opzionale dell'accesso pubblico e delle variabili d'ambiente.

## Esempio di utilizzo

```hcl
module "cloud_run" {
  source  = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/cloud_run?ref=main"
  project_id   = var.project_id
  service_name = "app-api"
  location     = "europe-west1"
  image        = "gcr.io/${var.project_id}/app-api:latest"
  env_vars = {
    PORT = "8080"
  }
  allow_unauthenticated = true
}
```

## Variabili

| Nome | Tipo | Default | Descrizione |
| --- | --- | --- | --- |
| `project_id` | string | n/a | ID del progetto GCP. |
| `service_name` | string | n/a | Nome del servizio Cloud Run. |
| `location` | string | `europe-west1` | Regione in cui distribuire il servizio. |
| `image` | string | n/a | Immagine container da eseguire. |
| `env_vars` | map(string) | `{}` | Mappa di variabili d'ambiente da passare al container. |
| `allow_unauthenticated` | bool | `true` | Concede l'invocazione pubblica del servizio quando true. |

## Output

| Nome | Descrizione |
| --- | --- |
| `service_url` | URL pubblico del servizio Cloud Run. |
