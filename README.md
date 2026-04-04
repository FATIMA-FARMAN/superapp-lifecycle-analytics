# SuperApp Customer Lifecycle Analytics Platform

> End-to-end customer lifecycle analytics for a FinTech SuperApp — tracking every stage from **onboarding and activation** through **engagement, loyalty, and reactivation** across $68.2M GMV and 224K+ transactions.

![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat-square&logo=dbt&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat-square&logo=postgresql&logoColor=white)
![Airflow](https://img.shields.io/badge/Airflow-017CEE?style=flat-square&logo=apache-airflow&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=flat-square&logo=duckdb&logoColor=black)

---

## Business Context

SuperApp needed full visibility into how customers move through the product lifecycle — from first signup to loyal repeat buyer. Core questions:
- Where do users drop off during **onboarding and first activation**?
- Which cohorts have the best **D7/D30 retention** and why?
- Who is at risk of churning and when to **reactivate** them?
- What drives **long-term loyalty** and maximises **customer LTV**?

---

## Customer Lifecycle Coverage

```
Acquisition → Onboarding → Activation → Engagement → Loyalty → Reactivation
     |              |            |            |           |           |
  Source mix    Signup flow   1st purchase  D7/D30     Repeat      Win-back
  tracking      drop-off      conversion    retention  purchase    campaigns
```

---

## What This Solves

| Business Problem | Analytics Solution |
|---|---|
| Where do new users drop off? | Onboarding funnel: signup to first purchase |
| Which activation tactics work? | A/B tested onboarding flows with significance testing |
| Who is churning? | Churn prediction from behavioural signals |
| How to win back churned users? | Reactivation funnel with campaign targeting |
| What drives loyalty? | Loyalty scoring tied to repeat purchase + engagement |
| What is each customer worth? | LTV modelling by segment and acquisition cohort |
| How do users behave in-app? | Behavioural event analysis: sessions, feature adoption |

---

## 1. Onboarding and Activation Analytics

Tracks every step of the new user journey — identifying drop-off and what drives first purchase:

```sql
SELECT
    onboarding_step,
    step_order,
    COUNT(DISTINCT user_id)                                                AS users,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (
        ORDER BY step_order ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), 1) AS completion_rate,
    ROUND(100 - COUNT(DISTINCT user_id) * 100.0 / NULLIF(LAG(COUNT(DISTINCT user_id)) OVER (
        ORDER BY step_order), 0), 1)                                       AS drop_off_rate
FROM onboarding_events
GROUP BY onboarding_step, step_order
ORDER BY step_order;
```

KPIs tracked: signup to ID verification to first product view to first purchase, time-to-first-purchase by channel, drop-off root cause, navigation guidance effectiveness.

---

## 2. A/B Testing Framework (Scipy + Statsmodels)

Full experiment lifecycle: sample size planning to results evaluation.

```python
import numpy as np
from scipy import stats
from statsmodels.stats.power import NormalIndPower

def plan_ab_test(baseline_rate, mde, alpha=0.05, power=0.8):
    """Sample size calculation using Statsmodels."""
    analysis = NormalIndPower()
    effect_size = mde / np.sqrt(baseline_rate * (1 - baseline_rate))
    n = analysis.solve_power(effect_size=effect_size, alpha=alpha, power=power)
    return {"sample_size_per_group": int(np.ceil(n)), "mde": mde,
            "alpha": alpha, "power": power}

def evaluate_ab_test(control_conv, control_n, treatment_conv, treatment_n):
    """Two-proportion z-test with 95% confidence interval."""
    p_c = control_conv / control_n
    p_t = treatment_conv / treatment_n
    p_pool = (control_conv + treatment_conv) / (control_n + treatment_n)
    se = np.sqrt(p_pool * (1 - p_pool) * (1/control_n + 1/treatment_n))
    z = (p_t - p_c) / se
    p_value = 2 * (1 - stats.norm.cdf(abs(z)))
    ci = stats.norm.interval(0.95, loc=p_t - p_c,
                             scale=np.sqrt(p_c*(1-p_c)/control_n + p_t*(1-p_t)/treatment_n))
    return {"control_rate": round(p_c*100,2), "treatment_rate": round(p_t*100,2),
            "lift_pct": round((p_t-p_c)*100,2), "p_value": round(p_value,4),
            "significant": p_value < 0.05, "95_ci": [round(x*100,2) for x in ci]}
```

Experiments supported: onboarding modal vs inline education, push notification timing, loyalty reward framing, reactivation email variants.

---

## 3. D7/D30 Retention Cohort Analysis

```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_retention_curves(conn):
    cohorts = pd.read_sql(
        "SELECT cohort_month, days_since_acquisition, retention_rate "
        "FROM mart_cohort_retention ORDER BY cohort_month, days_since_acquisition",
        conn
    )
    fig, ax = plt.subplots(figsize=(12, 6))
    for cohort, data in cohorts.groupby("cohort_month"):
        ax.plot(data["days_since_acquisition"], data["retention_rate"],
                label=cohort, marker="o", markersize=4)
    ax.set_xlabel("Days Since Acquisition")
    ax.set_ylabel("Retention Rate (%)")
    ax.set_title("Cohort Retention Curves — SuperApp")
    ax.legend(title="Cohort Month", bbox_to_anchor=(1.05, 1))
    plt.tight_layout()
    plt.savefig("docs/retention_curves.png", dpi=150)
```

---

## 4. Behavioural Event Analysis

Raw product events transformed into actionable insights:

```sql
-- Feature adoption from raw product events
SELECT
    event_name,
    COUNT(DISTINCT user_id)                                               AS unique_users,
    COUNT(*)                                                              AS total_events,
    ROUND(AVG(session_duration_seconds), 1)                               AS avg_session_sec,
    ROUND(COUNT(DISTINCT user_id) * 100.0 /
          MAX(COUNT(DISTINCT user_id)) OVER (), 1)                        AS adoption_rate_pct
FROM product_events
WHERE event_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY event_name
ORDER BY unique_users DESC;

-- Engagement score from behavioural signals
SELECT
    user_id,
    COUNT(DISTINCT session_id)                                            AS sessions_30d,
    COUNT(DISTINCT DATE(event_timestamp))                                 AS active_days_30d,
    SUM(CASE WHEN event_name = 'purchase_completed' THEN 1 ELSE 0 END)   AS purchases_30d,
    ROUND(COUNT(DISTINCT session_id) * 0.3 +
          COUNT(DISTINCT DATE(event_timestamp)) * 0.4 +
          SUM(CASE WHEN event_name = 'purchase_completed' THEN 1 ELSE 0 END) * 0.3, 2) AS engagement_score
FROM product_events
WHERE event_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY user_id;
```

---

## 5. Loyalty and CRM Analytics

Customer loyalty scoring, segmentation, and CRM targeting:

```sql
SELECT
    customer_id,
    total_purchases,
    total_gmv,
    avg_order_value,
    days_since_last_purchase,
    loyalty_points_balance,
    CASE
        WHEN total_purchases >= 10 AND days_since_last_purchase <= 30 THEN 'Champions'
        WHEN total_purchases >= 5  AND days_since_last_purchase <= 60 THEN 'Loyal'
        WHEN total_purchases >= 2  AND days_since_last_purchase <= 90 THEN 'Potential Loyal'
        WHEN days_since_last_purchase > 90                            THEN 'At Risk'
        ELSE 'New'
    END                                                                   AS loyalty_segment,
    ROUND(avg_order_value * purchase_frequency_monthly * 12
          * expected_lifespan_months, 2)                                  AS predicted_ltv
FROM customer_metrics;
```

---

## 6. Reactivation Funnel

Win-back analytics — identifying churned users and recommending incentives:

```sql
WITH churn_signals AS (
    SELECT
        user_id,
        DATEDIFF('day', MAX(last_purchase_date), CURRENT_DATE)           AS days_inactive,
        COUNT(*)                                                          AS historical_purchases,
        AVG(order_value)                                                  AS avg_order_value
    FROM customer_purchase_history
    GROUP BY user_id
)
SELECT
    user_id,
    days_inactive,
    historical_purchases,
    avg_order_value,
    CASE
        WHEN days_inactive BETWEEN 30 AND 60 THEN 'Early Churn — High Priority'
        WHEN days_inactive BETWEEN 61 AND 90 THEN 'Mid Churn — Medium Priority'
        WHEN days_inactive > 90              THEN 'Deep Churn — Points Incentive'
    END                                                                   AS reactivation_segment,
    ROUND(avg_order_value * historical_purchases * 0.15, 2)              AS recommended_incentive
FROM churn_signals
WHERE days_inactive >= 30
ORDER BY avg_order_value * historical_purchases DESC;
```

---

## Data Architecture

```
Staging:      stg_users | stg_product_events | stg_transactions | stg_loyalty
Intermediate: int_onboarding_funnel | int_user_engagement | int_cohort_retention | int_customer_ltv
Marts:        fct_lifecycle_events | fct_transactions | dim_customers
              mart_cohort_retention | mart_reactivation | mart_loyalty_crm
```

68 automated dbt tests — 100% pass rate. Daily Airflow DAG.

---

## Key Results

| Metric | Value |
|---|---|
| Total GMV analysed | $68,200,000 |
| Transactions | 224,000+ |
| Customers tracked | 50,000+ |
| BNPL adoption rate | 77.3% |
| On-time payment rate | 93.7% |
| Automated dbt tests | 68 (100% pass) |
| A/B experiments | Onboarding, retention, loyalty, reactivation |

---

## Tech Stack

| Layer | Tool |
|---|---|
| Transformation | dbt (staging to intermediate to marts) |
| Warehouse | DuckDB (local) · BigQuery (production-compatible) |
| Orchestration | Apache Airflow — daily DAG |
| BI / Reporting | Looker Studio |
| Python | Pandas · NumPy · Scipy · Statsmodels · Matplotlib · Scikit-learn |
| Event Analytics | Compatible with Amplitude behavioural event schema |
| Testing | dbt-utils · dbt-expectations |

---

## How to Run

```bash
pip install -r requirements.txt
dbt debug
dbt seed
dbt run
dbt test
```
