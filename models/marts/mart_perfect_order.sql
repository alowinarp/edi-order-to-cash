-- mart_perfect_order.sql
-- Grain: one row per PO (rolled up from line level)
-- Answers: did this PO meet ALL conditions of a perfect order?
-- Perfect Order = fully OTIF on every line + no invoice discrepancies on any line
-- This is the single most important KPI in CPG/retail supply chain scorecards

with otif as (
    select * from {{ ref('mart_otif') }}
),

invoice as (
    select * from {{ ref('mart_invoice_discrepancy') }}
),

-- Roll OTIF up to PO level
-- A PO fails OTIF if ANY line fails
po_otif_summary as (
    select
        po_number,
        count(*)                            as total_lines,
        sum(ordered_qty)                    as total_ordered_qty,
        sum(shipped_qty)                    as total_shipped_qty,
        round(
            sum(shipped_qty) / nullif(sum(ordered_qty), 0) * 100,
            2
        )                                   as po_fill_rate_pct,
        -- PO is OTIF only if every single line is OTIF
        logical_and(is_otif)                as is_po_otif,
        logical_and(is_shipped_on_time)     as is_po_shipped_on_time,
        logical_and(is_delivered_on_time)   as is_po_delivered_on_time,
        min(actual_ship_date)               as first_ship_date,
        max(actual_delivery_date)           as last_delivery_date
    from otif
    group by po_number
),

-- Roll invoice match up to PO level
-- A PO fails invoice match if ANY line has a discrepancy
po_invoice_summary as (
    select
        po_number,
        round(sum(invoiced_line_amount), 2) as total_invoiced_amt,
        round(sum(price_discrepancy_amt), 2) as total_price_discrepancy_amt,
        -- PO invoice is clean only if every line matched
        logical_and(is_invoice_matched)     as is_po_invoice_matched,
        countif(has_price_discrepancy)      as lines_with_price_discrepancy,
        countif(has_qty_discrepancy)        as lines_with_qty_discrepancy
    from invoice
    group by po_number
),

final as (
    select
        -- === PO identity ===
        o.po_number,
        o.total_lines,

        -- === OTIF metrics ===
        o.total_ordered_qty,
        o.total_shipped_qty,
        o.po_fill_rate_pct,
        o.is_po_otif,
        o.is_po_shipped_on_time,
        o.is_po_delivered_on_time,
        o.first_ship_date,
        o.last_delivery_date,

        -- === Invoice metrics ===
        i.total_invoiced_amt,
        i.total_price_discrepancy_amt,
        i.is_po_invoice_matched,
        i.lines_with_price_discrepancy,
        i.lines_with_qty_discrepancy,

        -- === THE KPI ===
        -- Perfect Order: OTIF on every line AND invoice clean on every line
        o.is_po_otif and i.is_po_invoice_matched
                                            as is_perfect_order,

        -- Audit
        current_timestamp()                 as _loaded_at

    from po_otif_summary as o
    left join po_invoice_summary as i
        on o.po_number = i.po_number
)

select * from final