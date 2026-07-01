# ------------------------------------------------------------------------------
# storage.tf — GCS buckets for EDI file handling
# Landing bucket receives incoming EDI flat files.
# Archive bucket stores processed files for audit trail.
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "edi_landing" {
  name          = "${var.project_id}-edi-landing"
  location      = var.region
  force_destroy = false
  storage_class = "STANDARD"

  # Auto-clean landing files after 30 days — they'll be in archive by then
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    purpose     = "landing"
  }
}

resource "google_storage_bucket" "edi_archive" {
  name          = "${var.project_id}-edi-archive"
  location      = var.region
  force_destroy = false
  storage_class = "NEARLINE"

  labels = {
    environment = var.environment
    purpose     = "archive"
  }
}
