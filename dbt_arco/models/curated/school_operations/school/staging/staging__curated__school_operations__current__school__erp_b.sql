-- Escolas oriundas do ERP-B
SELECT
    CAST(escola_id AS STRING)               AS source_id,
    name,
    CAST(NULL AS STRING)                    AS razao_social,
    cnpj,
    city,
    state,
    'erp_b'                                 AS source_system
FROM {{ ref('clean__erp_b__current__escola') }}
