SELECT
    CAST(doc_entry AS STRING)           AS source_delivery_id,
    CAST(base_order_entry AS STRING)    AS source_order_id,
    customer_code                       AS source_customer_id,
    delivery_date,
    status,
    is_cancelled,
    CAST(NULL AS INT64)                 AS quantity_delivered,
    CAST(NULL AS STRING)                AS delivery_status_normalized,
    'erp_a'                             AS source_system
FROM {{ ref('clean__erp_a__event__delivery') }}
