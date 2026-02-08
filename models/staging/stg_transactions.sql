{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from read_csv_auto('data/raw/transactions.csv', header=true)
),

renamed as (
    select
        "Transaction_ID" as transaction_id,
        "Customer_ID" as user_id,
        cast("Date" as date) as transaction_date,
        -- Add product column (you don't have this, so we'll derive it)
        case 
            when "Payment_Method" = 'Credit Card' then 'bnpl'
            when "Payment_Method" = 'PayPal' then 'food_delivery'
            when "Payment_Method" = 'Bank Transfer' then 'ride_sharing'
            else 'gaming'
        end as product,
        cast("Amount" as decimal(10,2)) as amount,
        "Status" as status,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
