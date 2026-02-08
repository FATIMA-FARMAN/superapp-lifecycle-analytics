{{ config(
    materialized='view'
) }}

WITH source AS (
    SELECT * FROM read_csv_auto('data/raw/transactions.csv', header=true)
),

standardized AS (
    SELECT
        "Transaction_ID"::VARCHAR AS transaction_id,
        "Customer_ID"::VARCHAR AS user_id,
        "Date"::DATE AS transaction_date,
        "Amount"::DECIMAL(18,2) AS amount,
        "Currency" AS currency,
        "Status" AS status,
        "Payment_Method" AS payment_method,
        "Product" AS product,  -- ADD THIS LINE
        CURRENT_TIMESTAMP AS _loaded_at
    FROM source
)

SELECT * FROM standardized
