{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from read_csv_auto('../data/raw/users.csv', header=true)
),

renamed as (
    select
        user_id,
        cast(registration_date as date) as registration_date,
        age,
        gender,
        country,
        user_segment,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
