WITH source AS (
    SELECT * FROM {{ source('raw', 'support_ticket') }}
),

final AS (
    SELECT
        CAST(id AS INT64)                               AS ticket_id,
        subject                                         AS subject,
        description                                     AS description,
        status                                          AS status,
        priority                                        AS priority,
        CAST(requester_id AS INT64)                     AS requester_id,
        CAST(assignee_id AS INT64)                      AS assignee_id,
        CAST(organization_id AS INT64)                  AS organization_id,
        custom_field_order_ref                          AS order_ref,
        REGEXP_REPLACE(
            COALESCE(custom_field_cnpj, ''), r'[^0-9]', '')  AS cnpj_cliente,
        CAST(created_at AS TIMESTAMP)                   AS created_at,
        CAST(updated_at AS TIMESTAMP)                   AS updated_at,
        CAST(solved_at AS TIMESTAMP)                    AS solved_at
    FROM source
)

SELECT * FROM final
