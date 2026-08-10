{{
  config(
    materialized = 'table'
  )
}}

-- Portfolio YTD por Account Manager
WITH contracts AS (
    SELECT
        account_manager_id,
        contract_id,
        grand_total,
        start_date,
        brand
    FROM {{ ref('curated__school_operations__event__contract') }}
    WHERE is_cancelled = FALSE
      AND EXTRACT(YEAR FROM start_date) = EXTRACT(YEAR FROM CURRENT_DATE())
),

orders_ytd AS (
    SELECT
        o.account_manager_id,
        COUNT(DISTINCT o.order_id)      AS total_orders,
        COUNT(DISTINCT o.school_id)     AS total_schools,
        SUM(i.line_total)               AS ordered_amount
    FROM {{ ref('curated__school_operations__event__order') }} o
    LEFT JOIN {{ ref('curated__school_operations__event__order_item') }} i
        ON i.order_id = o.order_id
    WHERE NOT o.is_cancelled
      AND EXTRACT(YEAR FROM o.order_date) = EXTRACT(YEAR FROM CURRENT_DATE())
    GROUP BY 1
),

contracts_agg AS (
    SELECT
        account_manager_id,
        COUNT(DISTINCT contract_id)     AS total_contracts,
        SUM(grand_total)                AS total_contracted_amount
    FROM contracts
    GROUP BY 1
),

tickets_ytd AS (
    SELECT
        o.account_manager_id,
        COUNT(t.ticket_id)              AS total_tickets,
        AVG(t.resolution_hours)         AS avg_resolution_hours
    FROM {{ ref('curated__school_operations__event__ticket') }} t
    LEFT JOIN {{ ref('curated__school_operations__event__order') }} o
        ON o.order_id = t.order_id
    WHERE EXTRACT(YEAR FROM t.created_at) = EXTRACT(YEAR FROM CURRENT_DATE())
    GROUP BY 1
),

ams AS (
    SELECT * FROM {{ ref('curated__school_operations__current__account_manager') }}
),

final AS (
    SELECT
        am.account_manager_id,
        am.name                                         AS account_manager_name,
        am.email,
        am.profile_name,
        EXTRACT(YEAR FROM CURRENT_DATE())               AS year,
        COALESCE(ca.total_contracts, 0)                 AS total_contracts,
        COALESCE(ca.total_contracted_amount, 0)         AS total_contracted_amount,
        COALESCE(oy.total_orders, 0)                    AS total_orders,
        COALESCE(oy.total_schools, 0)                   AS total_schools_served,
        COALESCE(oy.ordered_amount, 0)                  AS ordered_amount,
        COALESCE(ty.total_tickets, 0)                   AS total_tickets,
        ty.avg_resolution_hours,
        CURRENT_TIMESTAMP()                             AS dbt_updated_at
    FROM ams am
    LEFT JOIN contracts_agg ca  ON ca.account_manager_id = am.account_manager_id
    LEFT JOIN orders_ytd oy     ON oy.account_manager_id = am.account_manager_id
    LEFT JOIN tickets_ytd ty    ON ty.account_manager_id = am.account_manager_id
)

SELECT * FROM final
