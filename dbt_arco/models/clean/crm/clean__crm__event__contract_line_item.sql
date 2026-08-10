WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_contract_line_item') }}
),

final AS (
    SELECT
        Id                                  AS crm_line_item_id,
        ServiceContractId                   AS crm_contract_id,
        ProductId                           AS crm_product_id,
        MaterialType__c                     AS material_type,
        SchoolGrade__c                      AS school_grade,
        Segment__c                          AS segment,
        CAST(Quantity AS INT64)             AS quantity,
        CAST(UnitPrice AS FLOAT64)          AS unit_price,
        CAST(Discount AS FLOAT64)           AS discount,
        CAST(TotalPrice AS FLOAT64)         AS total_price,
        CAST(CreatedDate AS TIMESTAMP)      AS created_at
    FROM source
)

SELECT * FROM final
