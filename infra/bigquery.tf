# ------------------------------------------------------------------------------
# bigquery.tf — BigQuery datasets
# Two datasets: raw (new landing zone) and transform (existing dbt target).
# Think of these as two schemas in a traditional database.
# ------------------------------------------------------------------------------

# New dataset — raw EDI files land here via Airbyte (Task 12)
resource "google_bigquery_dataset" "raw" {
  dataset_id    = "edi_raw"
  friendly_name = "EDI Raw Landing"
  description   = "Raw EDI transaction data ingested by Airbyte before dbt transformation"
  location      = var.region

  labels = {
    environment = var.environment
    layer       = "raw"
  }
}

# Existing dataset — dbt's target. We'll import this into Terraform state
# so Terraform manages it going forward without recreating it.
resource "google_bigquery_dataset" "transform" {
  dataset_id    = "edi_order_to_cash"
  friendly_name = "EDI Order-to-Cash Transform"
  description   = "dbt staging, intermediate, and mart models"
  location      = var.region

  labels = {
    environment = var.environment
    layer       = "transform"
  }
}
