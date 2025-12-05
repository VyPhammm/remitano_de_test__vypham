{{- config(
    materialized = 'view'
)-}}

WITH dedup AS (
    SELECT
        TIMESTAMP(open_time) AS open_time,
        TIMESTAMP(close_time) AS close_time,
        base_currency,
        quote_currency,
        symbol,
        open,
        high,
        low,
        close,
        ROW_NUMBER() OVER (
            PARTITION BY open_time, base_currency, quote_currency
            ORDER BY close_time DESC
        ) AS rn
    FROM {{ source('raw_bronze', 'rates') }}
)
SELECT * FROM dedup WHERE rn = 1



