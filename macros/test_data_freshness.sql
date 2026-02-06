{% test data_freshness(model, column_name, max_days_old=7) %}

with freshness_check as (
    select
        max({{ column_name }}) as most_recent_date,
        datediff('day', max({{ column_name }}), current_date) as days_old
    from {{ model }}
)

select *
from freshness_check
where days_old > {{ max_days_old }}

{% endtest %}
