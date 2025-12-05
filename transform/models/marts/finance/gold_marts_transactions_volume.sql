{{- config(
    materialized = 'table',
)-}}

SELECT
    DATE_TRUNC('day', created_at) AS day,
    DATE_TRUNC('month', created_at) AS month,
    DATE_TRUNC('quarter', created_at) AS quarter,
    SUM(source_amount_usd) AS total_source_usd_volume,
    SUM(destination_amount_usd) AS total_destination_usd_volume,
FROM {{ ref('silver_int_transactions') }}
GROUP BY 1,2,3