{{
    config(
        materialized='view'
    )
}}

with events as (
    select * from {{ ref('stg_events') }}
),

user_daily_events as (
    select
        user_id,
        cast(event_timestamp as date) as event_date,
        event_type,
        count(*) as event_count
    from events
    group by 
        user_id,
        cast(event_timestamp as date),
        event_type
),

user_event_totals as (
    select
        user_id,
        event_type,
        count(distinct cast(event_timestamp as date)) as days_active,
        count(*) as total_events,
        min(event_timestamp) as first_event,
        max(event_timestamp) as last_event
    from events
    group by user_id, event_type
),

final as (
    select
        ude.user_id,
        ude.event_date,
        ude.event_type,
        ude.event_count as daily_event_count,
        uet.total_events,
        uet.days_active,
        current_timestamp as _loaded_at
    from user_daily_events ude
    left join user_event_totals uet 
        on ude.user_id = uet.user_id 
        and ude.event_type = uet.event_type
)

select * from final
