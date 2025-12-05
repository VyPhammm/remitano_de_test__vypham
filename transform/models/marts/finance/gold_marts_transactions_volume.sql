{{- config(
    materialized = 'incremental',
    incremental_strategy: 'merge',
    unique_key: 'marts_key',
    partition_by:{
        "field": "transaction_day",
        "data_type": "date"    
    },
    on_schema_change: 'append_new_column'
)-}}

SELECT
    {{ dbt_utils.surrogate_key(['DATE_TRUNC('day', created_at)', 'status']) }} AS marts_key,
    DATE_TRUNC('day', created_at) AS transaction_day,
    DATE_TRUNC('month', created_at) AS transaction_month,
    DATE_TRUNC('quarter', created_at) AS transaction_quarter,
    status,
    COUNT(txn_id) AS total_txn_cnt,
    COUNT(DISTINCT user_id) AS total_user_cnt, 
    SUM(source_amount_usd) AS total_source_usd_volume,
    SUM(destination_amount_usd) AS total_destination_usd_volume,
FROM {{ ref('silver_int_transactions') }}
GROUP BY 1,2,3,4