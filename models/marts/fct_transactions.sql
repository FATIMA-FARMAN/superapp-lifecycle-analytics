{{
    config(
        materialized='table',
        tags=['fact', 'daily']
    )
}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
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
        ) as product_transaction_number,
        row_number() over (
            partition by user_id 
            order by transaction_date
        ) as overall_transaction_number
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
    ts.overall_transaction_number,
    
    case 
        when ts.overall_transaction_number = 1 then 'First Transaction'
        when ts.overall_transaction_number = 2 then 'Second Transaction'
        when ts.overall_transaction_number <= 5 then 'Early Customer'
        when ts.overall_transaction_number <= 10 then 'Engaged Customer'
        else 'Power User'
    end as transaction_stage,
    
    current_timestamp as _updated_at
    
from transactions t
left join users u on t.user_id = u.user_id
left join transaction_sequences ts on t.transaction_id = ts.transaction_id
