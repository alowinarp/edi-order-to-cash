# ------------------------------------------------------------------------------
# main.tf — Terraform settings and Google Cloud provider
# This is the "profiles.yml" of Terraform — it tells Terraform which cloud
# provider to use, which version, and how to authenticate.
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # State stored locally for now. Task 11 (Dagster) is a natural point
  # to migrate to a GCS remote backend if needed.
}

provider "google" {
  project = var.project_id
  region  = var.region
  user_project_override = true
  billing_project       = var.project_id

  # Authentication: Terraform uses your gcloud CLI credentials automatically
  # (Application Default Credentials). No key file needed for local dev.
}
