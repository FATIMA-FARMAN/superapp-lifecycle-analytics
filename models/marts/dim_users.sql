{{
    config(
        materialized='table',
        tags=['dimension', 'daily']
    )
}}

with user_base as (
    select * from {{ ref('stg_users') }}
),

user_metrics as (
    select
        user_id,
        min(transaction_date) as first_transaction_date,
        max(transaction_date) as last_transaction_date,
        count(distinct transaction_id) as lifetime_transactions,
        count(distinct product) as products_used,
        sum(case when status = 'completed' then amount else 0 end) as lifetime_gmv,
        datediff('day', max(transaction_date), current_timestamp::date) as days_since_last_transaction
    from {{ ref('stg_transactions') }}
    group by user_id
)

select
    ub.user_id,
    ub.country,
    ub.user_segment,
    ub.registration_date,
    
    um.first_transaction_date,
    um.last_transaction_date,
    coalesce(um.lifetime_transactions, 0) as lifetime_transactions,
    coalesce(um.products_used, 0) as products_used,
    coalesce(um.lifetime_gmv, 0) as lifetime_gmv,
    coalesce(um.days_since_last_transaction, 
             datediff('day', ub.registration_date, current_timestamp::date)) as days_since_last_transaction,
    
    case 
        when um.first_transaction_date is not null 
        then datediff('day', um.first_transaction_date, um.last_transaction_date)
        else 0 
    end as user_tenure_days,
    
    {{ get_customer_segment('coalesce(um.lifetime_gmv, 0)', 'coalesce(um.lifetime_transactions, 0)') }} as customer_tier,
    
    case
        when um.last_transaction_date is null then 'Never Transacted'
        when um.days_since_last_transaction <= 30 then 'Active'
        when um.days_since_last_transaction <= 90 then 'At Risk'
        else 'Churned'
    end as recency_status,
    
    current_timestamp as _updated_at
    
from user_base ub
left join user_metrics um on ub.user_id = um.user_id
