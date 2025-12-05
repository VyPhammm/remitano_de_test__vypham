{{- config(
    materialized = 'incremental',
    incremental_strategy: 'append',
    unique_key: 'txn_id',
    partition_by:{
        "field": "created_date"
        "data_type": "date"
        "granularity": "day"       
    },
    on_schema_change: 'append_new_column'
)-}}

WITH trans AS (
    SELECT 
        *,
        DATE(created_at) AS created_date
    FROM {{ ref('bronze_stg_transactions') }}
)
, rates AS (
    SELECT *
    FROM {{ ref('bronze_stg_rates') }}
)
, final AS (
    SELECT
        t.txn_id,
        t.user_id,
        k.kyc_level,
        t.status,
        t.source_currency,
        t.destination_currency,
        t.created_at,
        t.source_amount,
        t.destination_amount,
        IF(source_currency = 'USD', 1, COALESCE(r.close, 0)) AS source_rate_usd,
        IF(destination_currency = 'USD', 1, COALESCE(r2.close, 0)) AS destination_rate_usd,
        t.created_date
    FROM trans t
    LEFT JOIN rates r ON 1=1
        AND t.source_currency = r.base_currency
        AND t.created_at BETWEEN r.open_time AND r.close_time
    LEFT JOIN rates r2 ON 1=1
        AND t.destination_currency = r2.base_currency
        AND t.created_at BETWEEN r2.open_time AND r2.close_time
)

SELECT 
    *,
    source_amount * source_rate_usd AS source_amount_usd,
    destination_amount * destination_rate_usd AS destination_amount_usd
FROM final