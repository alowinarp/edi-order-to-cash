-- Singular test: fill_rate_pct should never exceed 1.0
-- A value > 1.0 means more was shipped than ordered — a data integrity error.
-- Returns rows that violate the rule; zero rows = PASS.

SELECT
    po_number,
    line_number,
    fill_rate_pct
FROM {{ ref('int_po_shipment_matched') }}
WHERE fill_rate_pct > 1.0
