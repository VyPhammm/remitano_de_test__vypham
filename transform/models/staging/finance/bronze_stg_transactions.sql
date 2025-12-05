{{- config(
    materialized = 'view'
)-}}

SELECT
    txn_id,
    user_id,
    status,
    source_currency,
    destination_currency,
    TIMESTAMP(created_at) AS created_at,
    source_amount,
    destination_amount
FROM {{ source('raw_bronze', 'transactions') }}