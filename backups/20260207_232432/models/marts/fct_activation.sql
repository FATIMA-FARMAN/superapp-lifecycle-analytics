-- Activation events: first transaction by product
with first_transactions as (
    select
        user_id,
        product,
        min(transaction_date) as activation_date,
        min(transaction_id) as first_transaction_id
    from {{ ref('stg_transactions') }}
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
    datediff('day', ui.registration_date, ft.activation_date) as days_to_activate
from first_transactions ft
left join user_info ui on ft.user_id = ui.user_id
