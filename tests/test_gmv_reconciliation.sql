-- Test: GMV sum in dim_users matches fct_transactions
WITH user_gmv AS (
    SELECT 
        user_id,
        SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as calculated_gmv
    FROM {{ ref('fct_transactions') }}
    GROUP BY user_id
),

dim_gmv AS (
    SELECT 
        user_id,
        lifetime_gmv
    FROM {{ ref('dim_users') }}
)

SELECT 
    u.user_id,
    u.calculated_gmv,
    d.lifetime_gmv,
    ABS(u.calculated_gmv - d.lifetime_gmv) as difference
FROM user_gmv u
JOIN dim_gmv d ON u.user_id = d.user_id
WHERE ABS(u.calculated_gmv - d.lifetime_gmv) > 0.01
