-- Enhanced user dimension with RFM segmentation using custom macro
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
        datediff('day', max(transaction_date), current_date) as days_since_last_transaction
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
    um.lifetime_transactions,
    um.products_used,
    um.lifetime_gmv,
    um.days_since_last_transaction,
    datediff('day', um.first_transaction_date, um.last_transaction_date) as user_tenure_days,
    
    -- Custom macro for customer segmentation
    {{ get_customer_segment('um.lifetime_gmv', 'um.lifetime_transactions') }} as customer_tier,
    
    -- RFM components
    case
        when um.days_since_last_transaction <= 30 then 'Active'
        when um.days_since_last_transaction <= 90 then 'At Risk'
        else 'Churned'
    end as recency_status
    
from user_base ub
left join user_metrics um on ub.user_id = um.user_id
