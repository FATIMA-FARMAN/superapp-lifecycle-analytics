{% macro monthly_summary() %}
  {% set query %}
    select
        date_trunc('month', transaction_date) as month,
        count(distinct user_id) as active_users,
        sum(amount) as monthly_gmv,
        count(*) as transactions
    from {{ ref('stg_transactions') }}
    where payment_status = 'success'
    group by 1
    order by 1 desc
    limit 12
  {% endset %}

  {% set results = run_query(query) %}
  
  {% if execute %}
    {{ log("
📊 Monthly Summary (Last 12 Months):", info=True) }}
    {{ log("=" * 60, info=True) }}
    {% for row in results %}
      {{ log(row[0] ~ " | Users: " ~ row[1] ~ " | GMV: $" ~ row[2] ~ " | Txns: " ~ row[3], info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
