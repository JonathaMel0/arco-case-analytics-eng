{{
  config(
    materialized = 'table'
  )
}}

WITH erp_a AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__order_item__erp_a') }}
),

erp_b AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__order_item__erp_b') }}
),

unioned AS (
    SELECT * FROM erp_a
    UNION ALL
    SELECT * FROM erp_b
),

orders AS (
    SELECT order_id, source_order_id, source_system
    FROM {{ ref('curated__school_operations__event__order') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['i.source_system', 'i.source_order_id', 'i.source_line_id']) }}
                                            AS order_item_id,
        o.order_id,
        i.source_order_id,
        i.source_line_id,
        i.source_system,
        i.sku,
        i.description,
        i.quantity,
        i.delivered_quantity,
        i.unit_price,
        i.line_total,
        CURRENT_TIMESTAMP()                 AS dbt_updated_at
    FROM unioned i
    LEFT JOIN orders o
        ON  o.source_order_id = i.source_order_id
        AND o.source_system   = i.source_system
)

SELECT * FROM final
