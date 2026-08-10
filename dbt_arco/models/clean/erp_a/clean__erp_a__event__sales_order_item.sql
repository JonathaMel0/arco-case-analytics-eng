WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_a_sales_order_item') }}
),

final AS (
    SELECT
        CAST(DocEntry AS INT64)     AS doc_entry,
        CAST(LineNum AS INT64)      AS line_num,
        ItemCode                    AS sku,
        ItemName                    AS description,
        CAST(Quantity AS FLOAT64)   AS quantity,
        CAST(DelivrdQty AS FLOAT64) AS delivered_quantity,
        CAST(OpenQty AS FLOAT64)    AS open_quantity,
        CAST(ShipDate AS DATE)      AS ship_date,
        LineStatus                  AS line_status,
        CAST(Price AS FLOAT64)      AS unit_price,
        CAST(LineTotal AS FLOAT64)  AS line_total
    FROM source
)

SELECT * FROM final
