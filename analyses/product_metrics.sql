-- Product performance metrics
select
    product,
    count(distinct user_id) as total_users,
    count(distinct transaction_id) as total_transactions,
    sum(amount) as total_gmv,
    round(avg(amount), 2) as avg_transaction_value,
    round(sum(amount) / count(distinct user_id), 2) as gmv_per_user,
    round(count(distinct transaction_id) * 1.0 / count(distinct user_id), 2) as transactions_per_user
from {{ ref('fct_transactions') }}
where payment_status = 'success'
group by product
order by total_gmv desc
