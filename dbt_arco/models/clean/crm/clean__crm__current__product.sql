WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_product') }}
),

final AS (
    SELECT
        Id                              AS crm_product_id,
        ProductCode                     AS sku,
        Name                            AS name,
        Brand__c                        AS brand,
        MaterialType__c                 AS material_type,
        CAST(IsActive AS BOOL)          AS is_active,
        CAST(CreatedDate AS TIMESTAMP)  AS created_at
    FROM source
)

SELECT * FROM final
