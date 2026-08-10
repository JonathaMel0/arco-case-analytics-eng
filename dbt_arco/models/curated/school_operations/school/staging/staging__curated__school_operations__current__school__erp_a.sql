-- Escolas oriundas do ERP-A (clientes)
SELECT
    CAST(customer_code AS STRING)           AS source_id,
    name,
    CAST(NULL AS STRING)                    AS razao_social,
    cnpj,
    city,
    state,
    'erp_a'                                 AS source_system
FROM {{ ref('clean__erp_a__current__customer') }}
