{{ config(
    materialized='view'
) }}

WITH source AS (
    SELECT * FROM read_csv_auto('data/raw/events.csv', header=true)
),

standardized AS (
    SELECT
        event_id,
        user_id,
        event_type,
        event_timestamp::TIMESTAMP AS event_timestamp,
        CURRENT_TIMESTAMP AS _loaded_at
    FROM source
)

SELECT * FROM standardized
