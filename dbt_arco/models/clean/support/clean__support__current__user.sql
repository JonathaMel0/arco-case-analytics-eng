WITH source AS (
    SELECT * FROM {{ source('raw', 'support_user') }}
),

final AS (
    SELECT
        CAST(id AS INT64)               AS support_user_id,
        name                            AS name,
        email                           AS email,
        CAST(organization_id AS INT64)  AS organization_id,
        role                            AS role,
        CAST(is_active AS BOOL)         AS is_active,
        CAST(created_at AS TIMESTAMP)   AS created_at,
        CAST(updated_at AS TIMESTAMP)   AS updated_at
    FROM source
)

SELECT * FROM final
