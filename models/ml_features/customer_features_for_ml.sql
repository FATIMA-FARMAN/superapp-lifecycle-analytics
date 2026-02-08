{{
    config(
        materialized='table',
        tags=['ml', 'features']
    )
}}

-- Use only the working models
with events as (
    select * from {{ ref('stg_events') }}
),

event_summary as (
    select * from {{ ref('int_event_summary') }}
),

-- Event-based features only (since transactions are broken)
user_features as (
    select
        e.user_id,
        
        -- Event counts
        count(*) as total_events,
        count(distinct case when event_timestamp >= current_timestamp - interval '30 days' then event_id end) as events_last_30d,
        count(distinct case when event_timestamp >= current_timestamp - interval '7 days' then event_id end) as events_last_7d,
        
        -- Event types
        count(distinct event_type) as unique_event_types,
        sum(case when event_type = 'login' then 1 else 0 end) as login_events,
        sum(case when event_type = 'view' then 1 else 0 end) as view_events,
        sum(case when event_type = 'click' then 1 else 0 end) as click_events,
        sum(case when event_type = 'purchase' then 1 else 0 end) as purchase_events,
        
        -- Engagement metrics
        count(distinct date_trunc('day', event_timestamp)) as days_with_events,
        datediff('day', max(event_timestamp), current_timestamp) as days_since_last_event,
        
        -- Target (simple engagement-based)
        case when datediff('day', max(event_timestamp), current_timestamp) > 30 then 1 else 0 end as is_inactive
        
    from events e
    group by e.user_id
)

select * from user_features
