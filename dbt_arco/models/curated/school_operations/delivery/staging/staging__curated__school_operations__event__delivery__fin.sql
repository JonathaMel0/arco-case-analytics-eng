SELECT
    CAST(nota_fiscal_id AS STRING)          AS source_delivery_id,
    CAST(pedido_id AS STRING)               AS source_order_id,
    cnpj_cliente                            AS source_customer_id,
    COALESCE(actual_delivery_date, emissao_date)    AS delivery_date,
    delivery_status                         AS status,
    delivery_status IN ('devolvido', 'extraviado')  AS is_cancelled,
    quantity_delivered,
    delivery_status_normalized,
    'fin'                                   AS source_system
FROM {{ ref('clean__fin__event__nota_fiscal') }}
