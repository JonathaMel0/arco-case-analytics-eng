SELECT
    CAST(doc_entry AS STRING)           AS source_order_id,
    CAST(line_num AS STRING)            AS source_line_id,
    sku,
    description,
    quantity,
    delivered_quantity,
    unit_price,
    line_total,
    'erp_a'                             AS source_system
FROM {{ ref('clean__erp_a__event__sales_order_item') }}
