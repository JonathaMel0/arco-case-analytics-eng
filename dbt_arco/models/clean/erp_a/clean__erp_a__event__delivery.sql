WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_a_delivery') }}
),

final AS (
    SELECT
        CAST(DocEntry AS INT64)     AS doc_entry,
        CAST(DocNum AS INT64)       AS doc_num,
        CardCode                    AS customer_code,
        CAST(BaseEntry AS INT64)    AS base_order_entry,
        CAST(DocDate AS DATE)       AS delivery_date,
        DocStatus                   AS status,
        Cancelled = 'Y'             AS is_cancelled,
        CAST(CreateDate AS DATE)    AS created_date
    FROM source
    -- exclui datas claramente erradas (ex: 2204 por typo de 2024)
    WHERE EXTRACT(YEAR FROM CAST(DocDate AS DATE)) BETWEEN 2010 AND 2030
)

SELECT * FROM final
