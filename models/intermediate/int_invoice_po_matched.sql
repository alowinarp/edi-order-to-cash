-- int_invoice_po_matched.sql
-- Grain: one row per invoice line matched to its PO line
-- Joins the invoice (what was billed) to the PO (what was agreed)
-- Derives invoice discrepancy flags for the AP/finance KPI mart

with invoices as (
    select * from {{ ref('stg_810_invoices') }}
),

po as (
    select * from {{ ref('stg_850_purchase_orders') }}
),

matched as (
    select
        -- === Invoice identity ===
        inv.invoice_number,
        inv.invoice_date,
        inv.line_number,
        inv.upc_gtin,
        inv.product_desc,
        inv.vendor_name,

        -- === PO reference ===
        po.po_number,
        po.po_date,

        -- === Quantities ===
        po.ordered_qty,
        inv.invoiced_qty,

        -- === Prices ===
        po.unit_price             as po_unit_price,
        inv.invoiced_unit_price,
        inv.invoiced_line_amount,

        -- === Discrepancy calculations ===
        -- Price variance: positive = vendor overbilled, negative = underbilled
        inv.invoiced_unit_price - po.unit_price
                                  as price_variance,

        -- Qty variance: positive = invoiced more than ordered
        inv.invoiced_qty - po.ordered_qty
                                  as qty_variance,

        -- Price discrepancy: use 0.01 threshold to ignore floating point noise
        abs(inv.invoiced_unit_price - po.unit_price) > 0.01
                                  as has_price_discrepancy,

        -- Qty discrepancy: strict equality, qty should match exactly
        (inv.invoiced_qty - po.ordered_qty) != 0
                                  as has_qty_discrepancy,

        -- Invoice is fully matched only when BOTH flags are false
        not (abs(inv.invoiced_unit_price - po.unit_price) > 0.01)
        and not ((inv.invoiced_qty - po.ordered_qty) != 0)
                                  as is_invoice_matched,

        -- Audit timestamp
        current_timestamp()       as _loaded_at

    from invoices as inv
    -- LEFT JOIN: keeps invoice lines even if no PO match found
    -- An invoice with no PO is itself a discrepancy (maverick billing)
    left join po
        on  inv.po_number   = po.po_number
        and inv.line_number  = po.line_number
        and inv.upc_gtin     = po.upc_gtin
)

select * from matched