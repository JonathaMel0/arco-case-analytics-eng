WITH source AS (
    SELECT * FROM {{ source('raw', 'support_organization') }}
),

final AS (
    SELECT
        CAST(id AS INT64)       AS organization_id,
        name                    AS name,
        CASE
            WHEN LENGTH(REGEXP_REPLACE(COALESCE(external_id, ''), r'[^0-9]', '')) = 14
            THEN REGEXP_REPLACE(external_id, r'[^0-9]', '')
            ELSE NULL
        END                     AS cnpj,
        external_id             AS external_id_raw,
        CAST(created_at AS TIMESTAMP)   AS created_at,
        CAST(updated_at AS TIMESTAMP)   AS updated_at
    FROM source
)

SELECT * FROM final
