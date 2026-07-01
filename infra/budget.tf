# ------------------------------------------------------------------------------
# budget.tf — Billing budget alert
# Codifies the existing monthly budget alert so it's managed as code.
# No charges — this just configures email notifications at spend thresholds.
# ------------------------------------------------------------------------------

resource "google_billing_budget" "monthly" {
  billing_account = var.billing_account_id
  display_name    = "EDI Project Monthly Budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount)
    }
  }

  # Alert at 50%, 80%, and 100% of budget
  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.8
  }
  threshold_rules {
    threshold_percent = 1.0
  }
}
