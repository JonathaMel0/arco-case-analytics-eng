{{
  config(
    materialized = 'table'
  )
}}

-- Métricas mensais por escola: volume pedido, entregue, valor, tickets
WITH orders AS (
    SELECT
        school_id,
        DATE_TRUNC(order_date, MONTH)       AS month,
        COUNT(*)                            AS total_orders,
        COUNTIF(NOT is_cancelled)           AS active_orders,
        COUNTIF(is_cancelled)               AS cancelled_orders
    FROM {{ ref('curated__school_operations__event__order') }}
    WHERE order_date IS NOT NULL
    GROUP BY 1, 2
),

order_items AS (
    SELECT
        o.school_id,
        DATE_TRUNC(o.order_date, MONTH)     AS month,
        SUM(i.line_total)                   AS ordered_amount,
        SUM(i.quantity)                     AS ordered_quantity
    FROM {{ ref('curated__school_operations__event__order_item') }} i
    LEFT JOIN {{ ref('curated__school_operations__event__order') }} o
        ON o.order_id = i.order_id
    WHERE o.order_date IS NOT NULL
    GROUP BY 1, 2
),

deliveries AS (
    SELECT
        o.school_id,
        DATE_TRUNC(d.delivery_date, MONTH)  AS month,
        COUNT(*)                            AS total_deliveries,
        COUNTIF(NOT d.is_cancelled)         AS successful_deliveries,
        SUM(d.quantity_delivered)           AS quantity_delivered
    FROM {{ ref('curated__school_operations__event__delivery') }} d
    LEFT JOIN {{ ref('curated__school_operations__event__order') }} o
        ON o.order_id = d.order_id
    WHERE d.delivery_date IS NOT NULL
    GROUP BY 1, 2
),

tickets AS (
    SELECT
        school_id,
        DATE(DATE_TRUNC(created_at, MONTH))         AS month,
        COUNT(*)                            AS total_tickets,
        AVG(resolution_hours)               AS avg_resolution_hours
    FROM {{ ref('curated__school_operations__event__ticket') }}
    WHERE created_at IS NOT NULL
    GROUP BY 1, 2
),

schools AS (
    SELECT school_id, name, cnpj, city, state FROM {{ ref('curated__school_operations__current__school') }}
),

months_spine AS (
    SELECT DISTINCT month FROM (
        SELECT month FROM orders
        UNION DISTINCT
        SELECT month FROM deliveries
        UNION DISTINCT
        SELECT month FROM tickets
    )
),

school_months AS (
    SELECT s.school_id, ms.month
    FROM schools s
    CROSS JOIN months_spine ms
),

final AS (
    SELECT
        sm.school_id,
        sc.name                                     AS school_name,
        sc.cnpj,
        sc.city,
        sc.state,
        sm.month,
        COALESCE(o.total_orders, 0)                 AS total_orders,
        COALESCE(o.active_orders, 0)                AS active_orders,
        COALESCE(o.cancelled_orders, 0)             AS cancelled_orders,
        COALESCE(oi.ordered_amount, 0)              AS ordered_amount,
        COALESCE(oi.ordered_quantity, 0)            AS ordered_quantity,
        COALESCE(d.total_deliveries, 0)             AS total_deliveries,
        COALESCE(d.successful_deliveries, 0)        AS successful_deliveries,
        COALESCE(d.quantity_delivered, 0)           AS quantity_delivered,
        COALESCE(t.total_tickets, 0)                AS total_tickets,
        t.avg_resolution_hours,
        CURRENT_TIMESTAMP()                         AS dbt_updated_at
    FROM school_months sm
    LEFT JOIN schools sc        ON sc.school_id  = sm.school_id
    LEFT JOIN orders o          ON o.school_id   = sm.school_id AND o.month  = sm.month
    LEFT JOIN order_items oi    ON oi.school_id  = sm.school_id AND oi.month = sm.month
    LEFT JOIN deliveries d      ON d.school_id   = sm.school_id AND d.month  = sm.month
    LEFT JOIN tickets t         ON t.school_id   = sm.school_id AND t.month  = sm.month
)

SELECT * FROM final
