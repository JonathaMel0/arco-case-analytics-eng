WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_a_salesperson') }}
),

final AS (
    SELECT
        CAST(SlpCode AS INT64)  AS salesperson_code,
        SlpName                 AS name,
        Memo                    AS region,
        Active = 'Y'            AS is_active
    FROM source
)

SELECT * FROM final
