-- Test: Transaction numbers should be sequential per user
WITH sequenced AS (
    SELECT 
        user_id,
        overall_transaction_number,
        LAG(overall_transaction_number) OVER (
            PARTITION BY user_id 
            ORDER BY overall_transaction_number
        ) as prev_number
    FROM {{ ref('fct_transactions') }}
)

SELECT *
FROM sequenced
WHERE prev_number IS NOT NULL 
  AND overall_transaction_number != prev_number + 1
