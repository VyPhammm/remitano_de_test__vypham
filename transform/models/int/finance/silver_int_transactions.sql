{{- config(
    materialized = 'incremental',
    incremental_strategy: 'merge',
    unique_key: 'fact_key',
    partition_by:{
        "field": "created_date",
        "data_type": "date"     
    },
    on_schema_change: 'append_new_column'
)-}}

{%- if is_incremental() %}
  {%- set date_range = "DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)" %}
{%- endif %}


WITH trans AS (
    SELECT 
        *,
        DATE(created_at) AS created_date
    FROM {{ ref('bronze_stg_transactions') }}
    {%- if is_incremental() %}
    WHERE 1=1 
        AND DATE(created_at) >= {{ date_range }}
    {%- endif %}
)
, rates AS (
    SELECT *
    FROM {{ ref('bronze_stg_rates') }}
)
, final AS (
    SELECT
        t.txn_id AS fact_key,
        t.txn_id,
        t.user_id,
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