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
)

SELECT * FROM final
