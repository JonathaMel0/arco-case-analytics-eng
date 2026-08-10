WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_account') }}
),

final AS (
    SELECT
        Id                                                          AS crm_account_id,
        Name                                                        AS name,
        RazaoSocial__c                                              AS razao_social,
        REGEXP_REPLACE(CNPJ__c, r'[^0-9]', '')                     AS cnpj,
        Type                                                        AS account_type,
        ParentId                                                    AS parent_account_id,
        Phone                                                       AS phone,
        BillingCity                                                 AS city,
        BillingState                                                AS state,
        SalesModality__c                                            AS sales_modality,
        Segment__c                                                  AS segment,
        OwnerId                                                     AS owner_id,
        CAST(IsDeleted AS BOOL)                                     AS is_deleted,
        CAST(CreatedDate AS TIMESTAMP)                              AS created_at,
        CAST(LastModifiedDate AS TIMESTAMP)                         AS updated_at
    FROM source
)

SELECT * FROM final
