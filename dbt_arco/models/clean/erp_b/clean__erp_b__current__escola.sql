WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_b_escola') }}
),

final AS (
    SELECT
        CAST(id_escola AS INT64)                        AS escola_id,
        nome_escola                                     AS name,
        REGEXP_REPLACE(cnpj, r'[^0-9]', '')             AS cnpj,
        cidade                                          AS city,
        estado                                          AS state,
        email                                           AS email,
        CAST(id_vendedor AS INT64)                      AS vendedor_id,
        CAST(dt_cadastro AS DATE)                       AS created_date,
        CAST(dt_atualizacao AS DATE)                    AS updated_date
    FROM source
)

SELECT * FROM final
