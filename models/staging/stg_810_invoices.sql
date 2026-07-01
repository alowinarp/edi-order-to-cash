-- models/staging/stg_810_invoices.sql
-- Staging model for EDI 810 Invoices
-- Grain: one row per invoice line (invoice_number + line_number)

WITH source AS (

    SELECT * FROM {{ source('raw_edi', 'raw_810_invoices') }}

),

renamed AS (

    SELECT
        CAST(invoice_number AS STRING) AS invoice_number,
        CAST(po_number      AS STRING) AS po_number,
        CAST(line_number    AS INT64)  AS line_number,
        CAST(invoice_date AS DATE) AS invoice_date,
        CAST(po_date AS DATE)      AS po_date_on_invoice,
        CAST(ship_date AS DATE)    AS ship_date_on_invoice,
        TRIM(vendor_name)              AS vendor_name,
        CAST(upc_gtin     AS STRING)   AS upc_gtin,
        TRIM(product_desc)             AS product_desc,
        CAST(item_qty     AS INT64)    AS invoiced_qty,
        CAST(unit_price   AS NUMERIC)  AS invoiced_unit_price,
        COALESCE(CAST(allowance_charge_amt AS NUMERIC), 0.0) AS allowance_charge_amt,
        CAST(item_qty AS INT64) * CAST(unit_price AS NUMERIC) AS invoiced_line_amount,
        CURRENT_TIMESTAMP()            AS _loaded_at
    FROM source

),

validated AS (

    SELECT
        *,
        (invoiced_qty > 0)                       AS is_valid_qty,
        (invoiced_unit_price >= 0)               AS is_valid_price,
        (invoice_date >= po_date_on_invoice)     AS is_valid_invoice_date
    FROM renamed

)

SELECT * FROM validated
