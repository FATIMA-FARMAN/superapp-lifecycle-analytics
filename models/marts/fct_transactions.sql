-- Transaction-level facts with user attributes
with transactions as (
    select * from {{ ref('stg_transactions') }}
),

users as (
    select * from {{ ref('stg_users') }}
)

select
    t.transaction_id,
    t.user_id,
    u.country,
    u.user_segment,
    t.transaction_date,
    t.product,
    t.amount,
    t.payment_status,
    datediff('day', u.registration_date, t.transaction_date) as user_age_days,
    row_number() over (partition by t.user_id, t.product order by t.transaction_date) as product_transaction_number
from transactions t
left join users u on t.user_id = u.user_id
