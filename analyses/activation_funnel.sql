-- Activation funnel by segment
select
    u.user_segment,
    count(distinct u.user_id) as registered_users,
    count(distinct a.user_id) as activated_users,
    round(100.0 * count(distinct a.user_id) / count(distinct u.user_id), 2) as activation_rate,
    round(avg(a.days_to_activate), 1) as avg_days_to_activate
from {{ ref('dim_users') }} u
left join {{ ref('fct_activation') }} a on u.user_id = a.user_id
group by u.user_segment
order by activation_rate desc
