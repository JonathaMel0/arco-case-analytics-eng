WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_b_vendedor') }}
),

final AS (
    SELECT
        CAST(id_vendedor AS INT64)  AS vendedor_id,
        nome                        AS name,
        email                       AS email,
        regiao                      AS region,
        ativo = 'S'                 AS is_active
    FROM source
)

SELECT * FROM final
