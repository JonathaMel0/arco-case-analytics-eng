-- Account Managers: usuários CRM com perfil relevante que possuem contratos
WITH users AS (
    SELECT * FROM {{ ref('clean__crm__current__user') }}
    WHERE profile_name IN ('Account Manager', 'CS Manager', 'Sales Rep')
      AND is_active = TRUE
),

contracts AS (
    SELECT DISTINCT owner_id FROM {{ ref('clean__crm__event__service_contract') }}
    WHERE is_deleted = FALSE
),

-- Considera também accounts sob responsabilidade do usuário
accounts AS (
    SELECT DISTINCT owner_id FROM {{ ref('clean__crm__current__account') }}
    WHERE is_deleted = FALSE
),

final AS (
    SELECT
        u.crm_user_id                   AS account_manager_id,
        u.name                          AS name,
        u.email                         AS email,
        u.profile_name                  AS profile_name,
        u.is_active,
        CURRENT_TIMESTAMP()             AS dbt_updated_at
    FROM users u
    WHERE u.crm_user_id IN (SELECT owner_id FROM contracts)
       OR u.crm_user_id IN (SELECT owner_id FROM accounts)
)

SELECT * FROM final
