-- Monthly retention rates by cohort
with cohort_sizes as (
    select
        product,
        cohort_month,
        count(distinct user_id) as cohort_size
    from {{ ref('fct_retention') }}
    where months_since_activation = 0
    group by product, cohort_month
),

retention_data as (
    select
        r.product,
        r.cohort_month,
        r.months_since_activation,
        count(distinct r.user_id) as retained_users
    from {{ ref('fct_retention') }} r
    group by r.product, r.cohort_month, r.months_since_activation
)

select
    rd.product,
    rd.cohort_month,
    rd.months_since_activation,
    cs.cohort_size,
    rd.retained_users,
    round(100.0 * rd.retained_users / cs.cohort_size, 2) as retention_rate
from retention_data rd
join cohort_sizes cs 
    on rd.product = cs.product 
    and rd.cohort_month = cs.cohort_month
order by rd.product, rd.cohort_month, rd.months_since_activation
