{% macro get_customer_segment(gmv_column, transaction_count_column) %}
    case
        when {{ gmv_column }} >= 10000 and {{ transaction_count_column }} >= 20 then 'VIP'
        when {{ gmv_column }} >= 5000 and {{ transaction_count_column }} >= 10 then 'High Value'
        when {{ gmv_column }} >= 1000 and {{ transaction_count_column }} >= 5 then 'Regular'
        when {{ gmv_column }} > 0 then 'Low Value'
        else 'Inactive'
    end
{% endmacro %}
