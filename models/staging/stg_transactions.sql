{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from read_csv_auto('../data/raw/transactions.csv', header=true)
),

renamed as (
    select
        transaction_id,
        user_id,
        cast(transaction_date as date) as transaction_date,
        product,
        cast(amount as decimal(10,2)) as amount,
        payment_status,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
