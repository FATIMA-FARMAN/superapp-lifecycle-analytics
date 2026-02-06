{% macro get_cohort_month(date_column) %}
    date_trunc('month', {{ date_column }})
{% endmacro %}
