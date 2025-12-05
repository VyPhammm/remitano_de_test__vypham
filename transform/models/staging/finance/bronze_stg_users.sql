{{- config(
    materialized = 'view'
)-}}

SELECT
    user_id,
    kyc_level,
    TIMESTAMP(created_at) AS created_at,
    TIMESTAMP(updated_at) AS updated_at
FROM {{ source('raw_bronze', 'users') }}



