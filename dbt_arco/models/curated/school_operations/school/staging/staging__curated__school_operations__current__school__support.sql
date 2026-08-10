-- Escolas oriundas do Support (organizations com CNPJ válido)
SELECT
    CAST(organization_id AS STRING)         AS source_id,
    name,
    CAST(NULL AS STRING)                    AS razao_social,
    cnpj,
    CAST(NULL AS STRING)                    AS city,
    CAST(NULL AS STRING)                    AS state,
    'support'                               AS source_system
FROM {{ ref('clean__support__current__organization') }}
WHERE cnpj IS NOT NULL
