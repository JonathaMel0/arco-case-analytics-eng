WITH source AS (
    SELECT * FROM {{ source('raw', 'fin_nota_fiscal') }}
),

final AS (
    SELECT
        CAST(id_nf AS INT64)                            AS nota_fiscal_id,
        numero_nf                                       AS numero,
        serie_nf                                        AS serie,
        CAST(id_pedido_erp_b AS INT64)                  AS pedido_id,
        REGEXP_REPLACE(cnpj_cliente, r'[^0-9]', '')     AS cnpj_cliente,
        nome_cliente                                    AS nome_cliente,
        CAST(dt_emissao AS DATE)                        AS emissao_date,
        CAST(valor_total AS FLOAT64)                    AS total_value,
        CAST(valor_impostos AS FLOAT64)                 AS tax_value,
        cnpj_transportadora                             AS cnpj_transportadora,
        nome_transportadora                             AS transportadora,
        codigo_rastreio                                 AS tracking_code,
        CAST(dt_prevista_entrega AS DATE)               AS expected_delivery_date,
        CAST(NULLIF(dt_entrega_real, '') AS DATE)        AS actual_delivery_date,
        status_entrega                                  AS delivery_status,
        CASE status_entrega
            WHEN 'entregue'          THEN 'delivered'
            WHEN 'em_transito'       THEN 'in_transit'
            WHEN 'extraviado'        THEN 'lost'
            WHEN 'devolvido'         THEN 'returned'
            WHEN 'aguardando_coleta' THEN 'awaiting_pickup'
            ELSE status_entrega
        END                                             AS delivery_status_normalized,
        CAST(qtd_entregue AS INT64)                     AS quantity_delivered,
        CAST(dt_criacao AS TIMESTAMP)                   AS created_at
    FROM source
)

SELECT * FROM final
