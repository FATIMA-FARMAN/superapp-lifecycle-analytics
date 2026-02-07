-- User dimension with lifetime metrics
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
        sum(case when status = 'completed' then amount else 0 end) as lifetime_gmv
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
    datediff('day', um.first_transaction_date, um.last_transaction_date) as user_tenure_days
from user_base ub
left join user_metrics um on ub.user_id = um.user_id
