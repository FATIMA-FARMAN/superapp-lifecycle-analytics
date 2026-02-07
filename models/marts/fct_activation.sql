{{
    config(
        materialized='table',
        tags=['fact', 'daily']
    )
}}

with first_transactions as (
    select
        user_id,
        product,
        min(transaction_date) as activation_date,
        min(transaction_id) as first_transaction_id
    from {{ ref('stg_transactions') }}
    where status = 'completed'
    group by user_id, product
),

user_info as (
    select
        user_id,
        country,
        user_segment,
        registration_date
    from {{ ref('stg_users') }}
)

select
    ft.user_id,
    ui.country,
    ui.user_segment,
    ui.registration_date,
    ft.product,
    ft.activation_date,
    ft.first_transaction_id,
    
    datediff('day', ui.registration_date, ft.activation_date) as days_to_activate,
    
    case
        when datediff('day', ui.registration_date, ft.activation_date) <= 1 then 'Immediate (0-1 days)'
        when datediff('day', ui.registration_date, ft.activation_date) <= 7 then 'Fast (2-7 days)'
        when datediff('day', ui.registration_date, ft.activation_date) <= 30 then 'Normal (8-30 days)'
        when datediff('day', ui.registration_date, ft.activation_date) <= 90 then 'Slow (31-90 days)'
        else 'Very Slow (90+ days)'
    end as activation_speed,
    
    current_timestamp as _updated_at
    
from first_transactions ft
left join user_info ui on ft.user_id = ui.user_id
