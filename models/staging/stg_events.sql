{{
    config(
        materialized='view',
        tags=['staging', 'daily']
    )
}}

with source as (
    select * from read_csv_auto('data/raw/events.csv', header=true)
),

renamed as (
    select
        event_id,
        user_id,
        cast(event_timestamp as timestamp) as event_timestamp,
        event_type,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
