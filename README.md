# EDI Order-to-Cash Analytics Pipeline

Analytics Engineering portfolio project demonstrating a modern data stack implementation of an EDI-based Order-to-Cash pipeline.

## Stack
- **Orchestration Layer:** Raw EDI seed data (850 PO / 856 ASN / 810 Invoice)
- **Transformation:** dbt Core
- **Warehouse:** Google BigQuery
- **CI/CD:** GitHub Actions
- **Visualization:** Looker Studio / Evidence.dev (TBD)

## Data Flow
Raw EDI → Staging → Intermediate → Marts (Star Schema)

## Key Metrics
- Perfect Order Percentage
- Order-to-Ship Lead Time
- Invoice Discrepancy Rate
