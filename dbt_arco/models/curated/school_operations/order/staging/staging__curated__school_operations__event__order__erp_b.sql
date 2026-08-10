SELECT
    CAST(pedido_id AS STRING)               AS source_order_id,
    CAST(pedido_id AS STRING)               AS source_order_num,
    contract_number,
    CAST(escola_id AS STRING)               AS source_customer_id,
    order_date,
    expected_delivery_date                  AS due_date,
    status,
    is_cancelled,
    CAST(vendedor_id AS STRING)             AS salesperson_code,
    'erp_b'                                 AS source_system,
    CAST(created_at AS DATE)                AS created_at,
    CAST(updated_at AS DATE)                AS updated_at
FROM {{ ref('clean__erp_b__event__pedido') }}
