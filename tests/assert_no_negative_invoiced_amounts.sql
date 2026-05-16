-- Singular test: invoiced_line_amount should never be negative
-- A negative amount would indicate a credit memo or data entry error
-- that should be handled as a separate transaction type, not a regular invoice.
-- Returns rows that violate the rule; zero rows = PASS.

SELECT
    invoice_number,
    po_number,
    invoiced_line_amount
FROM {{ ref('stg_810_invoices') }}
WHERE invoiced_line_amount < 0
