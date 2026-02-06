{% macro performance_report() %}
  {% set query %}
    select 
        'dim_users' as model_name,
        count(*) as row_count
    from {{ ref('dim_users') }}
    union all
    select 
        'fct_transactions' as model_name,
        count(*) as row_count
    from {{ ref('fct_transactions') }}
    union all
    select 
        'fct_activation' as model_name,
        count(*) as row_count
    from {{ ref('fct_activation') }}
  {% endset %}

  {% set results = run_query(query) %}
  
  {% if execute %}
    {{ log("⚡ Model Performance Report:", info=True) }}
    {{ log("=" * 60, info=True) }}
    {% for row in results %}
      {{ log(row[0] ~ ": " ~ row[1] ~ " rows", info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
