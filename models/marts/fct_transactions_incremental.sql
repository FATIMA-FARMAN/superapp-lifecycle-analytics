{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        on_schema_change='append_new_columns',
        tags=['fact', 'incremental', 'daily']
    )
}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
    
    {% if is_incremental() %}
    where transaction_date > (select coalesce(max(transaction_date), '1900-01-01'::date) from {{ this }})
    {% endif %}
),

users as (
    select * from {{ ref('stg_users') }}
),

transaction_sequences as (
    select
        transaction_id,
        user_id,
        product,
        transaction_date,
        row_number() over (
            partition by user_id, product 
            order by transaction_date
        ) as product_transaction_number
    from transactions
)

select
    t.transaction_id,
    t.user_id,
    u.country,
    u.user_segment,
    t.transaction_date,
    t.product,
    t.amount,
    t.status,
    
    datediff('day', u.registration_date, t.transaction_date) as user_age_days,
    ts.product_transaction_number,
    
    current_timestamp as _updated_at
    
from transactions t
left join users u on t.user_id = u.user_id
left join transaction_sequences ts on t.transaction_id = ts.transaction_id
