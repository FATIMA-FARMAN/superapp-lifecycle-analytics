{% macro generate_date_spine(start_date, end_date) %}
    with date_spine as (
        select 
            dateadd('day', seq, date '{{ start_date }}') as date_day
        from 
            generate_series(
                0,
                datediff('day', date '{{ start_date }}', date '{{ end_date }}')
            ) as t(seq)
    )
    select * from date_spine
{% endmacro %}
