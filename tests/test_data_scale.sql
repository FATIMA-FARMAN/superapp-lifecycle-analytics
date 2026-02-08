-- Test: Verify production-scale data
WITH transaction_count AS (
    SELECT COUNT(*) as total_txns
    FROM {{ ref('fct_transactions') }}
)

SELECT *
FROM transaction_count
WHERE total_txns < 200000
