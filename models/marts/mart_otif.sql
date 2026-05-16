-- mart_otif.sql
-- Grain: one row per PO line
-- Answers: did each PO line ship and deliver on time, in full?
-- Primary consumer: retailer scorecards, supply chain ops dashboards

with po_shipment as (
    select * from {{ ref('int_po_shipment_matched') }}
),

final as (
    select
        -- === Dimensions (slice-and-dice axes for the dashboard) ===
        po_number,
        line_number,
        upc_gtin,
        product_desc,
        ship_to_duns,
        ship_to_name,
        po_date,

        -- === Date dimensions ===
        ship_date_requested,
        actual_ship_date,
        delivery_date_requested,
        actual_delivery_date,

        -- === Quantity metrics ===
        ordered_qty,
        shipped_qty,
        round(fill_rate_pct * 100, 2)   as fill_rate_pct,

        -- === OTIF component flags ===
        is_shipped_on_time,
        is_delivered_on_time,

        -- === The money metric ===
        is_otif,

        -- === Days variance (useful for trend analysis) ===
        date_diff(
            actual_ship_date,
            ship_date_requested,
            day
        )                               as ship_date_variance_days,

        date_diff(
            actual_delivery_date,
            delivery_date_requested,
            day
        )                               as delivery_date_variance_days,

        -- Audit
        current_timestamp()             as _loaded_at

    from po_shipment
)

select * from final