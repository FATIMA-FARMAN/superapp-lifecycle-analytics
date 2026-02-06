-- Monthly retention cohorts
with monthly_activity as (
    select
        user_id,
        product,
        date_trunc('month', transaction_date) as activity_month,
        sum(amount) as monthly_gmv,
        count(distinct transaction_id) as monthly_transactions
    from {{ ref('stg_transactions') }}
    where payment_status = 'success'
    group by user_id, product, date_trunc('month', transaction_date)
),

first_activity as (
    select
        user_id,
        product,
        min(activity_month) as cohort_month
    from monthly_activity
    group by user_id, product
)

select
    ma.user_id,
    ma.product,
    fa.cohort_month,
    ma.activity_month,
    ma.monthly_gmv,
    ma.monthly_transactions,
    datediff('month', fa.cohort_month, ma.activity_month) as months_since_activation
from monthly_activity ma
inner join first_activity fa 
    on ma.user_id = fa.user_id 
    and ma.product = fa.product
