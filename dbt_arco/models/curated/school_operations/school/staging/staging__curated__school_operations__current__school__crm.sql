-- Escolas oriundas do CRM (Type = 'School')
SELECT
    crm_account_id                          AS source_id,
    name,
    razao_social,
    cnpj,
    city,
    state,
    'crm'                                   AS source_system
FROM {{ ref('clean__crm__current__account') }}
WHERE account_type = 'School'
  AND is_deleted = FALSE
