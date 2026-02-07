{{
    config(
        materialized='view'
    )
}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

daily_metrics as (
    select
        transaction_date,
        product,
        
        -- Volume metrics
        count(*) as total_transactions,
        count(distinct user_id) as unique_users,
        
        -- Success metrics
        sum(case when status = 'completed' then 1 else 0 end) as successful_transactions,
        sum(case when status = 'failed' then 1 else 0 end) as failed_transactions,
        
        -- GMV metrics
        sum(case when status = 'completed' then amount else 0 end) as total_gmv,
        avg(case when status = 'completed' then amount else null end) as avg_transaction_amount,
        min(case when status = 'completed' then amount else null end) as min_transaction_amount,
        max(case when status = 'completed' then amount else null end) as max_transaction_amount,
        
        -- Success rate
        round(
            100.0 * sum(case when status = 'completed' then 1 else 0 end) / count(*),
            2
        ) as success_rate_pct
        
    from transactions
    group by transaction_date, product
),

monthly_metrics as (
    select
        date_trunc('month', transaction_date) as month,
        product,
        
        count(*) as monthly_transactions,
        count(distinct user_id) as monthly_unique_users,
        sum(case when status = 'completed' then amount else 0 end) as monthly_gmv,
        
        round(
            100.0 * sum(case when status = 'completed' then 1 else 0 end) / count(*),
            2
        ) as monthly_success_rate_pct
        
    from transactions
    group by date_trunc('month', transaction_date), product
),

product_totals as (
    select
        product,
        
        count(*) as product_total_transactions,
        count(distinct user_id) as product_unique_users,
        sum(case when status = 'completed' then amount else 0 end) as product_total_gmv,
        
        avg(case when status = 'completed' then amount else null end) as product_avg_amount,
        
        round(
            100.0 * sum(case when status = 'completed' then 1 else 0 end) / count(*),
            2
        ) as product_success_rate_pct
        
    from transactions
    group by product
),

overall_metrics as (
    select
        'overall' as metric_type,
        count(*) as total_transactions,
        count(distinct user_id) as total_unique_users,
        count(distinct transaction_date) as days_with_transactions,
        
        sum(case when status = 'completed' then amount else 0 end) as total_gmv,
        avg(case when status = 'completed' then amount else null end) as avg_amount,
        
        sum(case when product = 'bnpl' then 1 else 0 end) as bnpl_count,
        sum(case when product = 'shopping' then 1 else 0 end) as shopping_count,
        sum(case when product = 'wallet' then 1 else 0 end) as wallet_count,
        
        round(
            100.0 * sum(case when status = 'completed' then 1 else 0 end) / count(*),
            2
        ) as overall_success_rate_pct
        
    from transactions
)

select
    dm.*,
    mm.monthly_transactions,
    mm.monthly_gmv,
    mm.monthly_success_rate_pct,
    pt.product_total_gmv,
    pt.product_avg_amount,
    pt.product_success_rate_pct,
    current_timestamp as _loaded_at
from daily_metrics dm
left join monthly_metrics mm 
    on date_trunc('month', dm.transaction_date) = mm.month 
    and dm.product = mm.product
left join product_totals pt 
    on dm.product = pt.product
