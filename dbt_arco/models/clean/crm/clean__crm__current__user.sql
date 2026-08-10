WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_user') }}
),

final AS (
    SELECT
        Id                                  AS crm_user_id,
        Name                                AS name,
        Email                               AS email,
        ProfileName                         AS profile_name,
        CAST(IsActive AS BOOL)              AS is_active,
        CAST(CreatedDate AS TIMESTAMP)      AS created_at,
        CAST(LastModifiedDate AS TIMESTAMP) AS updated_at
    FROM source
)

SELECT * FROM final
