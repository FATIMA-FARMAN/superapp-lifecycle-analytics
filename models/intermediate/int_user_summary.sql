{{
    config(
        materialized='view'
    )
}}

with users as (
    select * from {{ ref('stg_users') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

events as (
    select * from {{ ref('stg_events') }}
),

user_transactions as (
    select
        user_id,
        count(*) as total_transactions,
        count(distinct product) as unique_products_used,
        sum(case when status = 'completed' then 1 else 0 end) as successful_transactions,
        sum(case when status = 'failed' then 1 else 0 end) as failed_transactions,
        sum(case when status = 'completed' then amount else 0 end) as total_gmv,
        avg(case when status = 'completed' then amount else null end) as avg_transaction_amount,
        min(transaction_date) as first_transaction_date,
        max(transaction_date) as last_transaction_date,
        
        -- Product-specific metrics
        sum(case when product = 'bnpl' and status = 'completed' then 1 else 0 end) as bnpl_transactions,
        sum(case when product = 'shopping' and status = 'completed' then 1 else 0 end) as shopping_transactions,
        sum(case when product = 'wallet' and status = 'completed' then 1 else 0 end) as wallet_transactions,
        
        sum(case when product = 'bnpl' and status = 'completed' then amount else 0 end) as bnpl_gmv,
        sum(case when product = 'shopping' and status = 'completed' then amount else 0 end) as shopping_gmv,
        sum(case when product = 'wallet' and status = 'completed' then amount else 0 end) as wallet_gmv
        
    from transactions
    group by user_id
),

user_events as (
    select
        user_id,
        count(*) as total_events,
        count(distinct event_type) as unique_event_types,
        
        sum(case when event_type = 'app_open' then 1 else 0 end) as app_open_events,
        sum(case when event_type = 'product_view' then 1 else 0 end) as product_view_events,
        sum(case when event_type = 'add_to_cart' then 1 else 0 end) as add_to_cart_events,
        
        min(event_timestamp) as first_event_timestamp,
        max(event_timestamp) as last_event_timestamp
        
    from events
    group by user_id
),

final as (
    select
        u.user_id,
        u.registration_date,
        u.country,
        u.user_segment,
        
        coalesce(ut.total_transactions, 0) as total_transactions,
        coalesce(ut.successful_transactions, 0) as successful_transactions,
        coalesce(ut.total_gmv, 0) as total_gmv,
        ut.avg_transaction_amount,
        
        coalesce(ut.bnpl_transactions, 0) as bnpl_transactions,
        coalesce(ut.shopping_transactions, 0) as shopping_transactions,
        coalesce(ut.wallet_transactions, 0) as wallet_transactions,
        
        coalesce(ue.total_events, 0) as total_events,
        
        case 
            when ut.first_transaction_date is not null 
            then datediff('day', u.registration_date, ut.first_transaction_date)
            else null 
        end as days_to_first_transaction,
        
        case 
            when ut.total_transactions > 0 then 1 else 0 
        end as is_activated,
        
        current_timestamp as _loaded_at
        
    from users u
    left join user_transactions ut on u.user_id = ut.user_id
    left join user_events ue on u.user_id = ue.user_id
)

select * from final
