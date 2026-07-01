# ------------------------------------------------------------------------------
# variables.tf — Input variables for the EDI Order-to-Cash infrastructure
# Think of these like dbt's vars: — they parameterize your config so nothing
# is hardcoded. Actual values live in terraform.tfvars (gitignored).
# ------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region for resources"
  type        = string
  default     = "asia-southeast1"
}

variable "billing_account_id" {
  description = "GCP billing account ID for budget alerts"
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 10
}

variable "environment" {
  description = "Environment label (dev, staging, prod)"
  type        = string
  default     = "dev"
}
