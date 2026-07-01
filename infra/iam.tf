# ------------------------------------------------------------------------------
# iam.tf — Service accounts with least-privilege IAM bindings
# Each tool (Dagster, Airbyte) gets its own SA so you can audit and revoke
# access independently. Never share SAs across tools.
# ------------------------------------------------------------------------------

# --- Dagster Service Account (Task 11: orchestration) ---
resource "google_service_account" "dagster_sa" {
  account_id   = "dagster-orchestrator"
  display_name = "Dagster Orchestrator"
  description  = "Runs dbt jobs and manages pipeline orchestration"
}

# Dagster needs to: run BigQuery jobs, read/write tables, trigger dbt
resource "google_project_iam_member" "dagster_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user"          # Run queries
  member  = "serviceAccount:${google_service_account.dagster_sa.email}"
}

resource "google_project_iam_member" "dagster_bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"    # Read/write tables
  member  = "serviceAccount:${google_service_account.dagster_sa.email}"
}

# --- Airbyte Service Account (Task 12: ingestion) ---
resource "google_service_account" "airbyte_sa" {
  account_id   = "airbyte-ingestion"
  display_name = "Airbyte Ingestion"
  description  = "Loads raw EDI data from GCS into BigQuery"
}

# Airbyte needs to: read GCS files, write to BigQuery raw dataset
resource "google_project_iam_member" "airbyte_gcs_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"   # Read GCS files
  member  = "serviceAccount:${google_service_account.airbyte_sa.email}"
}

resource "google_project_iam_member" "airbyte_bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"    # Write to raw dataset
  member  = "serviceAccount:${google_service_account.airbyte_sa.email}"
}

resource "google_project_iam_member" "airbyte_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user"          # Run load jobs
  member  = "serviceAccount:${google_service_account.airbyte_sa.email}"
}

# Airbyte needs storage.buckets.get to list bucket metadata (required by GCS connector)
resource "google_storage_bucket_iam_member" "airbyte_landing_reader" {
  bucket = google_storage_bucket.edi_landing.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.airbyte_sa.email}"
}
