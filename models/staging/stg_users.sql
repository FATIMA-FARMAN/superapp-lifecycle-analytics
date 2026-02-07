{{
    config(
        materialized='view',
        tags=['staging', 'daily']
    )
}}

with source as (
    select * from read_csv_auto('data/raw/users.csv', header=true)
),

renamed as (
    select
        "Customer_ID" as user_id,
        cast("Registration_Date" as date) as registration_date,
        "Country" as country,
        "Customer_Segment" as user_segment,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
