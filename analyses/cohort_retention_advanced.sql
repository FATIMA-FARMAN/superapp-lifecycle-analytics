-- Advanced cohort retention with custom macros
with cohort_base as (
    select
        user_id,
        product,
        {{ get_cohort_month('activation_date') }} as cohort_month
    from {{ ref('fct_activation') }}
),

monthly_activity as (
    select
        user_id,
        product,
        {{ get_cohort_month('transaction_date') }} as activity_month,
        sum(amount) as monthly_revenue
    from {{ ref('fct_transactions') }}
    where payment_status = 'success'
    group by 1, 2, 3
),

cohort_retention as (
    select
        cb.cohort_month,
        cb.product,
        ma.activity_month,
        datediff('month', cb.cohort_month, ma.activity_month) as months_since_cohort,
        count(distinct ma.user_id) as retained_users,
        sum(ma.monthly_revenue) as cohort_revenue
    from cohort_base cb
    inner join monthly_activity ma 
        on cb.user_id = ma.user_id 
        and cb.product = ma.product
    group by 1, 2, 3, 4
)

select
    cohort_month,
    product,
    months_since_cohort,
    retained_users,
    cohort_revenue,
    round(100.0 * retained_users / first_value(retained_users) over (
        partition by cohort_month, product 
        order by months_since_cohort
    ), 2) as retention_rate_pct
from cohort_retention
order by cohort_month desc, product, months_since_cohort
