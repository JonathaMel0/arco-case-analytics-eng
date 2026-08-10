WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_b_item_pedido') }}
),

final AS (
    SELECT
        CAST(id_item AS INT64)              AS item_id,
        CAST(id_pedido AS INT64)            AS pedido_id,
        cod_produto                         AS sku,
        desc_produto                        AS description,
        CAST(qtd_pedida AS INT64)           AS quantity,
        CAST(preco_unitario AS FLOAT64)     AS unit_price,
        CAST(qtd_pedida AS FLOAT64)
            * CAST(preco_unitario AS FLOAT64) AS line_total,
        CAST(dt_criacao AS TIMESTAMP)       AS created_at
    FROM source
)

SELECT * FROM final
