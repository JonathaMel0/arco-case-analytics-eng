WITH source AS (
    SELECT * FROM {{ source('raw', 'erp_a_customer') }}
),

final AS (
    SELECT
        CardCode                                                AS customer_code,
        CardName                                                AS name,
        REGEXP_REPLACE(CNPJ, r'[^0-9]', '')                    AS cnpj,
        City                                                    AS city,
        State                                                   AS state,
        Phone1                                                  AS phone,
        E_Mail                                                  AS email,
        CAST(SlpCode AS INT64)                                  AS salesperson_code,
        CAST(CreateDate AS DATE)                                AS created_date,
        CAST(UpdateDate AS DATE)                                AS updated_date
    FROM source
)

SELECT * FROM final
