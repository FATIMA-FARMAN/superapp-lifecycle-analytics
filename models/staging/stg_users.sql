{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from read_csv_auto('data/raw/users.csv', header=true)
),

renamed as (
    select
        user_id,
        country,
        age,
        -- Add user_segment based on age
        case 
            when age < 30 then 'new'
            when age < 50 then 'regular'
            else 'vip'
        end as user_segment,
        -- Generate a registration_date
        date '2024-01-01' as registration_date,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
