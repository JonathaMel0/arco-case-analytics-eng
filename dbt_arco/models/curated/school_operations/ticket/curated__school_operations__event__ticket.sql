{{
  config(
    materialized = 'table'
  )
}}

WITH tickets AS (
    SELECT * FROM {{ ref('clean__support__event__ticket') }}
),

tags AS (
    SELECT
        ticket_id,
        STRING_AGG(tag ORDER BY tag) AS tags
    FROM {{ ref('clean__support__event__ticket_tag') }}
    GROUP BY 1
),

organizations AS (
    SELECT organization_id, cnpj
    FROM {{ ref('clean__support__current__organization') }}
    WHERE cnpj IS NOT NULL
),

schools AS (
    SELECT school_id, cnpj
    FROM {{ ref('curated__school_operations__current__school') }}
    WHERE cnpj IS NOT NULL
),

orders AS (
    SELECT
        order_id,
        source_order_id,
        source_system
    FROM {{ ref('curated__school_operations__event__order') }}
),

final AS (
    SELECT
        t.ticket_id,
        t.subject,
        t.status,
        t.priority,
        t.requester_id,
        t.assignee_id,
        t.organization_id,
        t.order_ref,
        t.cnpj_cliente,
        s.school_id,
        o.order_id,
        tg.tags,
        t.created_at,
        t.updated_at,
        t.solved_at,
        TIMESTAMP_DIFF(t.solved_at, t.created_at, HOUR) AS resolution_hours,
        CURRENT_TIMESTAMP()                              AS dbt_updated_at
    FROM tickets t
    LEFT JOIN tags tg       ON tg.ticket_id      = t.ticket_id
    LEFT JOIN organizations org ON org.organization_id = t.organization_id
    LEFT JOIN schools s     ON s.cnpj              = org.cnpj
    LEFT JOIN orders o      ON o.source_order_id   = t.order_ref
                           AND o.source_system   = 'erp_b'
)

SELECT * FROM final
