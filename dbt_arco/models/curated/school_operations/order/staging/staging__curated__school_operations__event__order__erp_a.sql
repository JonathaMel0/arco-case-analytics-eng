SELECT
    CAST(doc_entry AS STRING)               AS source_order_id,
    CAST(doc_num AS STRING)                 AS source_order_num,
    contract_number,
    customer_code                           AS source_customer_id,
    order_date,
    due_date,
    status,
    is_cancelled,
    CAST(salesperson_code AS STRING)         AS salesperson_code,
    'erp_a'                                 AS source_system,
    created_date                            AS created_at,
    updated_date                            AS updated_at
FROM {{ ref('clean__erp_a__event__sales_order') }}
