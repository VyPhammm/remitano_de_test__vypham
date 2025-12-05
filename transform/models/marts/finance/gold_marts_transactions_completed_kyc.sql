{{- config(
    materialized = 'incremental',
    incremental_strategy: 'merge',
    unique_key: 'marts_key',
    partition_by:{
        "field": "created_date",
        "data_type": "date"  
    },
    on_schema_change: 'append_new_column'
)-}}

{%- if is_incremental() %}
  {%- set date_range = "DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)" %}
{%- endif %}

WITH kyc AS (
    SELECT *
    FROM {{ ref('silver_int__user_kyc_history') }}
)

SELECT
    t.txn_id AS marts_key,
    t.txn_id,
    t.user_id,
    t.status,
    k.kyc_level,
    t.source_currency,
    t.destination_currency,
    t.created_at,
    t.source_amount,
    t.destination_amount,
    t.source_rate_usd,
    t.destination_rate_usd,
    t.source_amount_usd,
    t.destination_amount_usd,
    t.created_date
FROM {{ ref('silver_int_transactions') }} t
LEFT JOIN kyc k ON 1=1
    AND t.user_id = k.user_id
    AND t.created_at >= k.effective_from
    AND (t.created_at < k.effective_to OR k.effective_to IS NULL)
WHERE 1=1
    AND status = 'completed'
    {%- if is_incremental() %}
    AND DATE(created_date) >= {{ date_range }}
    {%- endif %}