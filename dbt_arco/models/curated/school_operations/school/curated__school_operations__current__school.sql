{{
  config(
    materialized = 'table'
  )
}}

WITH crm AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__current__school__crm') }}
),

erp_a AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__current__school__erp_a') }}
),

erp_b AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__current__school__erp_b') }}
),

support AS (
    SELECT * FROM {{ ref('staging__curated__school_operations__current__school__support') }}
),

-- União de todos os CNPJs distintos como base de identidade
all_cnpjs AS (
    SELECT DISTINCT cnpj FROM crm   WHERE cnpj IS NOT NULL AND LENGTH(cnpj) = 14
    UNION DISTINCT
    SELECT DISTINCT cnpj FROM erp_a WHERE cnpj IS NOT NULL AND LENGTH(cnpj) = 14
    UNION DISTINCT
    SELECT DISTINCT cnpj FROM erp_b WHERE cnpj IS NOT NULL AND LENGTH(cnpj) = 14
    UNION DISTINCT
    SELECT DISTINCT cnpj FROM support WHERE cnpj IS NOT NULL AND LENGTH(cnpj) = 14
),

joined AS (
    SELECT
        base.cnpj,
        crm.source_id                                                       AS crm_account_id,
        erp_a.source_id                                                     AS erp_a_customer_code,
        erp_b.source_id                                                     AS erp_b_escola_id,
        support.source_id                                                   AS support_org_id,
        COALESCE(crm.name, erp_a.name, erp_b.name, support.name)           AS name,
        COALESCE(crm.razao_social)                                          AS razao_social,
        COALESCE(crm.city, erp_a.city, erp_b.city)                         AS city,
        COALESCE(crm.state, erp_a.state, erp_b.state)                      AS state
    FROM all_cnpjs base
    LEFT JOIN crm     ON crm.cnpj     = base.cnpj
    LEFT JOIN erp_a   ON erp_a.cnpj   = base.cnpj
    LEFT JOIN erp_b   ON erp_b.cnpj   = base.cnpj
    LEFT JOIN support ON support.cnpj  = base.cnpj
),

final AS (
    SELECT
        -- school_id: usa CRM id como master; se não existir, gera sintético
        COALESCE(crm_account_id, CONCAT('NCRM-', cnpj))    AS school_id,
        cnpj,
        name,
        razao_social,
        city,
        state,
        crm_account_id,
        erp_a_customer_code,
        erp_b_escola_id,
        support_org_id,
        CURRENT_TIMESTAMP()                                 AS dbt_updated_at
    FROM joined
)

SELECT * FROM final
