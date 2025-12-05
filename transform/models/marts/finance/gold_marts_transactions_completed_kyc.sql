



WITH kyc AS (
    SELECT *
    FROM {{ ref('silver_int__user_kyc_history') }}
)

SELECT
    



    LEFT JOIN kyc k ON 1=1
        AND t.user_id = k.user_id
        AND t.created_at >= k.effective_from
        AND (t.created_at < k.effective_to OR k.effective_to IS NULL)

SELECT
    kyc_level,
    COUNT(*) AS completed_tx_count,
    SUM(amount_usd) AS completed_tx_usd
FROM {{ ref('stg_transaction_kyc') }}
WHERE status = 'COMPLETED'
GROUP BY 1