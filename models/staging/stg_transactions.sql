{{
    config(
        materialized='view',
        tags=['staging', 'daily']
    )
}}

with source as (
    select * from read_csv_auto('data/raw/transactions.csv', header=true)
),

renamed as (
    select
        "Transaction_ID" as transaction_id,
        "Customer_ID" as user_id,
        cast("Transaction_Date" as date) as transaction_date,
        "Product" as product,
        cast("Amount" as decimal(10,2)) as amount,
        "Status" as status,
        current_timestamp as _loaded_at
    from source
)

select * from renamed
