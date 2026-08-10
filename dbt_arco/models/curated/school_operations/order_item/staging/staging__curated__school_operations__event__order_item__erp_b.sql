SELECT
    CAST(pedido_id AS STRING)           AS source_order_id,
    CAST(item_id AS STRING)             AS source_line_id,
    sku,
    description,
    CAST(quantity AS FLOAT64)           AS quantity,
    CAST(NULL AS FLOAT64)               AS delivered_quantity,
    unit_price,
    line_total,
    'erp_b'                             AS source_system
FROM {{ ref('clean__erp_b__event__item_pedido') }}
