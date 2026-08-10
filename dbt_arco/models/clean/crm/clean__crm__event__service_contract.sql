WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_service_contract') }}
),

final AS (
    SELECT
        Id                                          AS crm_contract_id,
        UPPER(TRIM(ContractNumber))                 AS contract_number,
        Name                                        AS name,
        AccountId                                   AS crm_account_id,
        OwnerId                                     AS owner_id,
        Status                                      AS status,
        Status = 'Cancelled'                        AS is_cancelled,
        CAST(StartDate AS DATE)                     AS start_date,
        CAST(EndDate AS DATE)                       AS end_date,
        Brand__c                                    AS brand,
        CAST(GrandTotal AS FLOAT64)                 AS grand_total,
        CAST(TotalPrice AS FLOAT64)                 AS total_price,
        CAST(Discount AS FLOAT64)                   AS discount,
        MarketingModel__c                           AS marketing_model,
        CAST(IsDeleted AS BOOL)                     AS is_deleted,
        CAST(CreatedDate AS TIMESTAMP)              AS created_at,
        CAST(LastModifiedDate AS TIMESTAMP)         AS updated_at
    FROM source
)

SELECT * FROM final
