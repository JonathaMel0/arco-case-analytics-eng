WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_b_pedido') }}
),

final AS (
    SELECT
        CAST(id_pedido AS INT64)                        AS pedido_id,
        CAST(id_escola AS INT64)                        AS escola_id,
        UPPER(TRIM(num_contrato))                       AS contract_number,
        CAST(dt_pedido AS DATE)                         AS order_date,
        CAST(dt_entrega_prevista AS DATE)               AS expected_delivery_date,
        UPPER(status)                                   AS status_raw,
        CASE
            WHEN UPPER(status) IN ('C', 'CANCELLED', 'CANCELADO') THEN 'cancelled'
            WHEN UPPER(status) IN ('E', 'DELIVERED', 'ENTREGUE')  THEN 'delivered'
            ELSE 'in_progress'
        END                                             AS status,
        UPPER(status) IN ('C', 'CANCELLED', 'CANCELADO') AS is_cancelled,
        CAST(id_vendedor AS INT64)                      AS vendedor_id,
        CAST(dt_criacao AS TIMESTAMP)                   AS created_at,
        CAST(dt_atualizacao AS TIMESTAMP)               AS updated_at
    FROM source
)

SELECT * FROM final
