{% snapshot user_segment_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='check',
      check_cols=['user_segment', 'country']
    )
}}

select
    user_id,
    user_segment,
    country,
    registration_date
from {{ ref('stg_users') }}

{% endsnapshot %}
