-- models/staging/stg_856_asn.sql
-- Staging model for EDI 856 Advance Ship Notices
-- Grain: one row per shipment line (bol_shipment_number + po_number + line_number)

WITH source AS (

    SELECT * FROM {{ ref('raw_856_asn') }}

),

renamed AS (

    SELECT
        CAST(bol_shipment_number AS STRING) AS bol_shipment_number,
        CAST(po_number           AS STRING) AS po_number,
        CAST(line_number         AS INT64)  AS line_number,
        CAST(ship_date AS DATE)     AS actual_ship_date,
        CAST(delivery_date AS DATE) AS actual_delivery_date,
        CAST(ship_to_duns AS STRING)        AS ship_to_duns,
        CAST(upc_gtin     AS STRING)        AS upc_gtin,
        CAST(item_qty     AS INT64)         AS shipped_qty,
        CAST(unit_price   AS NUMERIC)       AS unit_price,
        COALESCE(CAST(pallet_case_qty AS INT64), 0) AS pallet_case_qty,
        CURRENT_TIMESTAMP()                 AS _loaded_at
    FROM source

),

validated AS (

    SELECT
        *,
        (shipped_qty > 0)                              AS is_valid_qty,
        (unit_price >= 0)                              AS is_valid_price,
        (actual_delivery_date >= actual_ship_date)     AS is_valid_delivery_sequence
    FROM renamed

)

SELECT * FROM validated
