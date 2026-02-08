-- Test: Retention rates should be between 0 and 100%
SELECT *
FROM {{ ref('fct_retention') }}
WHERE retention_rate < 0 OR retention_rate > 100
