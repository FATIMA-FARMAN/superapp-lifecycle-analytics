{{ config(
    materialized='view'
) }}

WITH source AS (
    SELECT * FROM read_csv_auto('data/raw/users.csv', header=true)
),

standardized AS (
    SELECT
        user_id::VARCHAR AS user_id,
        name AS user_name,
        age AS age,
        country,
        gender,
        -- Add missing columns that marts expect
        CURRENT_DATE - INTERVAL (user_id % 730) DAY AS registration_date,  -- Synthetic registration dates
        CASE 
            WHEN (user_id % 10) < 2 THEN 'vip'
            WHEN (user_id % 10) < 6 THEN 'regular'
            ELSE 'new'
        END AS user_segment,
        CURRENT_TIMESTAMP AS _loaded_at
    FROM source
)

SELECT * FROM standardized
