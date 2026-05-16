-- Singular test: when a price discrepancy exists, vendor must have overbilled.
-- price_variance = invoiced_unit_price - unit_price (PO)
-- If has_price_discrepancy is TRUE but price_variance <= 0, the vendor
-- underbilled — which contradicts how we seeded and defined discrepancies.
-- Returns rows that violate the rule; zero rows = PASS.

SELECT
    invoice_number,
    po_number,
    price_variance,
    has_price_discrepancy
FROM {{ ref('mart_invoice_discrepancy') }}
WHERE has_price_discrepancy = TRUE
  AND price_variance <= 0
