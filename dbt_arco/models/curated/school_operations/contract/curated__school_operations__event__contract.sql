WITH contracts AS (
    SELECT * FROM {{ ref('clean__crm__event__service_contract') }}
    WHERE is_deleted = FALSE
),

schools AS (
    SELECT school_id, crm_account_id FROM {{ ref('curated__school_operations__current__school') }}
    WHERE crm_account_id IS NOT NULL
),

ams AS (
    SELECT account_manager_id FROM {{ ref('curated__school_operations__current__account_manager') }}
),

final AS (
    SELECT
        c.crm_contract_id                               AS contract_id,
        c.contract_number,
        s.school_id,
        c.crm_account_id,
        -- owner_id é o AM responsável pelo contrato
        CASE WHEN am.account_manager_id IS NOT NULL
             THEN c.owner_id ELSE NULL END               AS account_manager_id,
        c.owner_id                                      AS owner_crm_user_id,
        c.status,
        c.is_cancelled,
        c.start_date,
        c.end_date,
        c.brand,
        c.grand_total,
        c.total_price,
        c.discount,
        c.marketing_model,
        c.created_at,
        c.updated_at,
        CURRENT_TIMESTAMP()                             AS dbt_updated_at
    FROM contracts c
    LEFT JOIN schools s ON s.crm_account_id = c.crm_account_id
    LEFT JOIN ams am     ON am.account_manager_id = c.owner_id
)

SELECT * FROM final
