# ------------------------------------------------------------------------------
# outputs.tf — Values printed after terraform apply
# Like dbt's log output — confirms what was created and surfaces key IDs
# you'll need when configuring Dagster and Airbyte.
# ------------------------------------------------------------------------------

output "raw_dataset_id" {
  description = "BigQuery raw landing dataset"
  value       = google_bigquery_dataset.raw.dataset_id
}

output "transform_dataset_id" {
  description = "BigQuery transform dataset (dbt target)"
  value       = google_bigquery_dataset.transform.dataset_id
}

output "landing_bucket" {
  description = "GCS bucket for incoming EDI files"
  value       = google_storage_bucket.edi_landing.name
}

output "archive_bucket" {
  description = "GCS bucket for processed EDI files"
  value       = google_storage_bucket.edi_archive.name
}

output "dagster_sa_email" {
  description = "Dagster service account email"
  value       = google_service_account.dagster_sa.email
}

output "airbyte_sa_email" {
  description = "Airbyte service account email"
  value       = google_service_account.airbyte_sa.email
}
