# Cloud SQL MySQL Module

Provisiona una istanza Cloud SQL per MySQL con opzioni di configurazione di base (tier, storage, availability) e la creazione opzionale di un database e della password di root.

## Esempio di utilizzo

```hcl
module "mysql" {
  source  = "git::https://github.com/simonevernile/repo.git//catalogo/gcp/mysql?ref=main"
  project_id      = var.project_id
  instance_name   = "app-mysql"
  region          = "europe-west1"
  tier            = "db-f1-micro"
  database_name   = "app_db"
  root_password   = var.mysql_root_password
  enable_public_ip = false
}
```

## Variabili

| Nome | Tipo | Default | Descrizione |
| --- | --- | --- | --- |
| `project_id` | string | n/a | ID del progetto GCP. |
| `instance_name` | string | n/a | Nome dell'istanza Cloud SQL. |
| `region` | string | `europe-west1` | Regione in cui creare l'istanza. |
| `database_version` | string | `MYSQL_8_0` | Versione del database MySQL. |
| `tier` | string | `db-f1-micro` | Tier della macchina (es. `db-f1-micro`, `db-custom-2-4096`). |
| `disk_size` | number | `20` | Dimensione del disco dati in GB. |
| `disk_type` | string | `PD_SSD` | Tipo di disco (`PD_SSD` o `PD_HDD`). |
| `availability_type` | string | `ZONAL` | Tipo di disponibilità dell'istanza (`ZONAL` o `REGIONAL`). |
| `deletion_protection` | bool | `true` | Protegge l'istanza dalla distruzione. |
| `root_password` | string | `null` | Password per l'utente root; se `null` non viene gestita da Terraform. |
| `database_name` | string | `null` | Crea un database con il nome indicato se valorizzato. |
| `enable_public_ip` | bool | `false` | Abilita l'indirizzo IPv4 pubblico. |

## Output

| Nome | Descrizione |
| --- | --- |
| `connection_name` | Nome di connessione usato dai client. |
| `self_link` | Self link dell'istanza Cloud SQL. |
| `database` | Nome del database creato (se impostato). |
