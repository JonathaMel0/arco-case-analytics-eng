WITH source AS (
    SELECT * FROM {{ source('raw', 'support_ticket_tag') }}
),

final AS (
    SELECT
        CAST(ticket_id AS INT64)    AS ticket_id,
        tag                         AS tag
    FROM source
)

SELECT * FROM final
