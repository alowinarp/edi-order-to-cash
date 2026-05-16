-- models/staging/stg_850_purchase_orders.sql
-- Staging model for EDI 850 Purchase Orders
-- Grain: one row per PO line (po_number + line_number)

WITH source AS (

    SELECT * FROM {{ ref('raw_850_purchase_orders') }}

),

renamed AS (

    SELECT
        CAST(po_number      AS STRING)  AS po_number,
        CAST(line_number    AS INT64)   AS line_number,
        CAST(po_date AS DATE)       AS po_date,
        CAST(ship_date AS DATE)     AS ship_date_requested,
        CAST(delivery_date AS DATE) AS delivery_date_requested,
        CAST(ship_to_duns   AS STRING)  AS ship_to_duns,
        TRIM(ship_to_name)              AS ship_to_name,
        CAST(upc_gtin       AS STRING)  AS upc_gtin,
        TRIM(product_desc)              AS product_desc,
        CAST(item_qty       AS INT64)   AS ordered_qty,
        CAST(unit_price     AS NUMERIC) AS unit_price,
        COALESCE(CAST(allowance_charge_amt AS NUMERIC), 0.0) AS allowance_charge_amt,
        CURRENT_TIMESTAMP()             AS _loaded_at
    FROM source

),

validated AS (

    SELECT
        *,
        (ordered_qty > 0)                                        AS is_valid_qty,
        (unit_price >= 0)                                        AS is_valid_price,
        (ship_date_requested >= po_date)                         AS is_valid_ship_date,
        (delivery_date_requested >= ship_date_requested)         AS is_valid_delivery_date
    FROM renamed

)

SELECT * FROM validated
