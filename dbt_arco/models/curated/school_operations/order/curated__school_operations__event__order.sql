{{
  config(
    materialized = 'table'
  )
}}

WITH erp_a AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__order__erp_a') }}
),

erp_b AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__event__order__erp_b') }}
),

unioned AS (
    SELECT * FROM erp_a
    UNION ALL
    SELECT * FROM erp_b
),

schools AS (
    SELECT
        school_id,
        erp_a_customer_code,
        erp_b_escola_id,
        cnpj
    FROM {{ ref('curated__school_operations__current__school') }}
),

contracts AS (
    SELECT contract_number, contract_id, account_manager_id, school_id
    FROM {{ ref('curated__school_operations__event__contract') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['o.source_system', 'o.source_order_id']) }}
                                                            AS order_id,
        o.source_order_id,
        o.source_order_num,
        o.source_system,
        o.contract_number,
        c.contract_id,
        COALESCE(
            c.school_id,
            CASE
                WHEN o.source_system = 'erp_a' THEN sa.school_id
                WHEN o.source_system = 'erp_b' THEN sb.school_id
            END
        )                                                   AS school_id,
        c.account_manager_id,
        o.order_date,
        o.due_date,
        o.status,
        o.is_cancelled,
        o.salesperson_code,
        o.created_at,
        o.updated_at,
        CURRENT_TIMESTAMP()                                 AS dbt_updated_at
    FROM unioned o
    LEFT JOIN contracts c   ON c.contract_number = o.contract_number
    LEFT JOIN schools sa    ON sa.erp_a_customer_code = o.source_customer_id
                           AND o.source_system = 'erp_a'
    LEFT JOIN schools sb    ON sb.erp_b_escola_id = o.source_customer_id
                           AND o.source_system = 'erp_b'
)

SELECT * FROM final
