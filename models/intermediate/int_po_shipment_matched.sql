-- int_po_shipment_matched.sql
-- Grain: one row per PO line matched to its ASN line
-- Joins the purchase order (what was ordered) to the ASN (what was shipped)
-- Derives OTIF components: fill rate, on-time ship, on-time delivery

with po as (
    select * from {{ ref('stg_850_purchase_orders') }}
),

asn as (
    select * from {{ ref('stg_856_asn') }}
),

matched as (
    select
        -- === PO identity ===
        po.po_number,
        po.line_number,
        po.upc_gtin,
        po.product_desc,

        -- === PO order details ===
        po.ordered_qty,
        po.unit_price             as po_unit_price,
        po.ship_date_requested,
        po.delivery_date_requested,
        po.ship_to_duns,
        po.ship_to_name,
        po.po_date,

        -- === ASN shipment actuals ===
        asn.bol_shipment_number,
        asn.shipped_qty,
        asn.actual_ship_date,
        asn.actual_delivery_date,
        asn.pallet_case_qty,

        -- === OTIF components ===
        -- Fill rate: what fraction of the ordered qty was actually shipped?
        -- Cast to FLOAT64 to avoid integer division returning 0
        safe_divide(
            cast(asn.shipped_qty as float64),
            cast(po.ordered_qty  as float64)
        )                         as fill_rate_pct,

        -- Was the shipment picked up / left the dock on or before the PO's requested ship date?
        asn.actual_ship_date <= po.ship_date_requested
                                  as is_shipped_on_time,

        -- Did the freight arrive at the DC on or before the requested delivery date?
        asn.actual_delivery_date <= po.delivery_date_requested
                                  as is_delivered_on_time,

        -- OTIF = fully shipped AND both date flags are TRUE
        -- This is the single boolean a retailer scorecard will penalize you on
        (
            safe_divide(
                cast(asn.shipped_qty as float64),
                cast(po.ordered_qty  as float64)
            ) = 1.0
            and asn.actual_ship_date     <= po.ship_date_requested
            and asn.actual_delivery_date <= po.delivery_date_requested
        )                         as is_otif,

        -- Audit timestamp
        current_timestamp()       as _loaded_at

    from po
    -- LEFT JOIN: keeps PO lines that have no ASN yet (unshipped orders)
    -- Change to INNER JOIN only if you want to report on matched pairs only
    left join asn
        on  po.po_number   = asn.po_number
        and po.line_number  = asn.line_number
        and po.upc_gtin     = asn.upc_gtin
)

select * from matched