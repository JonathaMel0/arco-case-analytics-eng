WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_a_sales_order') }}
),

final AS (
    SELECT
        CAST(DocEntry AS INT64)             AS doc_entry,
        CAST(DocNum AS INT64)               AS doc_num,
        CardCode                            AS customer_code,
        UPPER(TRIM(NumAtCard))              AS contract_number,
        CAST(DocDate AS DATE)               AS order_date,
        CAST(DocDueDate AS DATE)            AS due_date,
        Cancelled = 'Y'                     AS is_cancelled,
        CASE
            WHEN Cancelled = 'Y'    THEN 'cancelled'
            WHEN DocStatus = 'O'    THEN 'open'
            ELSE 'closed'
        END                                 AS status,
        Comments                            AS comments,
        CAST(SlpCode AS INT64)              AS salesperson_code,
        CAST(CreateDate AS DATE)            AS created_date,
        CAST(UpdateDate AS DATE)            AS updated_date
    FROM source
)

SELECT * FROM final
