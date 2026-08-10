{{
  config(
    materialized = 'table'
  )
}}

WITH erp_a AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__delivery__erp_a') }}
),

fin AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__delivery__fin') }}
),

unioned AS (
    SELECT * FROM erp_a
    UNION ALL
    SELECT * FROM fin
),

orders AS (
    SELECT order_id, source_order_id, source_system
    FROM {{ ref('curated__school_operations__event__order') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['d.source_system', 'd.source_delivery_id']) }}
                                                    AS delivery_id,
        d.source_delivery_id,
        d.source_order_id,
        d.source_system,
        -- Para ERP-A, source_system da order é 'erp_a'; para fin, order vem do erp_b
        CASE
            WHEN d.source_system = 'erp_a' THEN oa.order_id
            WHEN d.source_system = 'fin'   THEN ob.order_id
        END                                         AS order_id,
        d.delivery_date,
        d.status,
        d.is_cancelled,
        d.quantity_delivered,
        d.delivery_status_normalized,
        CURRENT_TIMESTAMP()                         AS dbt_updated_at
    FROM unioned d
    LEFT JOIN orders oa
        ON  oa.source_order_id = d.source_order_id
        AND oa.source_system   = 'erp_a'
        AND d.source_system    = 'erp_a'
    LEFT JOIN orders ob
        ON  ob.source_order_id = d.source_order_id
        AND ob.source_system   = 'erp_b'
        AND d.source_system    = 'fin'
)

SELECT * FROM final
WHERE EXTRACT(YEAR FROM delivery_date) BETWEEN 2010 AND 2030
