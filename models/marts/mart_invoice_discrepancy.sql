-- mart_invoice_discrepancy.sql
-- Grain: one row per invoice line matched to its PO line and ASN line
-- Answers: where does the invoice differ from what was agreed (PO) and what was shipped (ASN)?
-- qty_variance compares invoiced vs SHIPPED (ASN) — correct AP reconciliation logic
-- price_variance compares invoiced vs PO unit price — the contractual agreement

with invoice_po as (
    select * from {{ ref('int_invoice_po_matched') }}
),

asn as (
    select
        po_number,
        line_number,
        upc_gtin,
        shipped_qty
    from {{ ref('stg_856_asn') }}
),

final as (
    select
        -- === Identity ===
        inv.invoice_number,
        inv.invoice_date,
        inv.po_number,
        inv.po_date,
        inv.line_number,
        inv.upc_gtin,
        inv.product_desc,
        inv.vendor_name,

        -- === Quantities (three-way view) ===
        inv.ordered_qty,
        asn.shipped_qty,
        inv.invoiced_qty,

        -- === Prices ===
        inv.po_unit_price,
        inv.invoiced_unit_price,
        inv.invoiced_line_amount,

        -- === Price discrepancy (vs PO contract) ===
        -- Unchanged from int layer — PO is the contractual benchmark
        inv.price_variance,
        inv.has_price_discrepancy,

        -- === Qty discrepancy (vs ASN shipped — Option A) ===
        -- Vendor should invoice what they shipped, not what was ordered
        inv.invoiced_qty - asn.shipped_qty      as qty_variance,
        (inv.invoiced_qty - asn.shipped_qty) != 0
                                                as has_qty_discrepancy,

        -- === Final match flag (recomputed with corrected qty logic) ===
        not (inv.has_price_discrepancy)
        and (inv.invoiced_qty - asn.shipped_qty) = 0
                                                as is_invoice_matched,

        -- === Dollar impact of price discrepancy ===
        -- How much money is at stake on this line?
        round(
            inv.price_variance * inv.invoiced_qty,
            2
        )                                       as price_discrepancy_amt,

        -- Audit
        current_timestamp()                     as _loaded_at

    from invoice_po as inv
    left join asn
        on  inv.po_number  = asn.po_number
        and inv.line_number = asn.line_number
        and inv.upc_gtin    = asn.upc_gtin
)

select * from final