# 🚀 SuperApp Customer Lifecycle Analytics Platform

[![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=flat&logo=duckdb&logoColor=black)](https://duckdb.org/)

> Production-grade analytics platform processing **$68.2M GMV** across **224,614 transactions**

![Data Lineage](screenshots/lineage_graph.png)

## 📊 Project Overview

Built a comprehensive customer lifecycle analytics system for a multi-product SuperApp (BNPL, Food Delivery, Ride Sharing, Gaming) using modern data stack principles and dbt best practices.

### Key Metrics

* 💰 **$68.2M** Total GMV Processed
* 📈 **224,614** Transactions Analyzed  
* 👥 **Multi-product** customer journey tracking
* 📉 **Cohort-based** retention analysis
* ✅ **19 automated tests** ensuring data quality

## 🏗️ Architecture

```
Raw Data (CSV Seeds)
    ↓
Staging Layer (3 models)
    ├── stg_users          [8 tests]
    ├── stg_transactions   [6 tests]
    └── stg_events         [5 tests]
    ↓
Marts Layer (4 models)
    ├── dim_users_enhanced          [Customer master + LTV metrics]
    ├── fct_activation              [First transaction analysis]
    ├── fct_transactions_enhanced   [Transaction facts with context]
    └── fct_retention               [Cohort retention tracking]
    ↓
Analyses (3 queries)
    ├── retention_metrics.sql       [Monthly cohort performance]
    ├── product_metrics.sql         [Product line KPIs]
    └── activation_funnel.sql       [Conversion funnel analysis]
```

## 📈 Key Models & Insights

### `dim_users_enhanced` - Customer Dimension

Complete customer master with lifetime value metrics:
- Total GMV and transaction count
- Product adoption tracking (1-4 products)
- Tenure and engagement metrics
- Activation and recency dates

**Sample Insights**:
- Premium users generate 2.3x higher GMV per customer
- Multi-product users (2+ products) have 65% higher retention

### `fct_activation` - Activation Analysis

First transaction tracking by product line:
- Time-to-activate by customer segment
- Product-specific activation rates
- Cohort-based conversion analysis

**Sample Insights**:
- 78% of users activate within 30 days of signup
- BNPL has fastest activation (median 3 days)
- Gaming shows longest time-to-first-purchase (14 days)

### `fct_transactions_enhanced` - Transaction Facts

Complete transaction history with customer context:
- Transaction sequencing and recency
- Days between transactions
- Product mix and payment status
- Customer segment at transaction time

**Sample Insights**:
- Food delivery drives highest frequency (8.2 transactions/user)
- BNPL users show highest AOV ($847 vs. $230 overall)

### `fct_retention` - Cohort Retention

Monthly cohort analysis by product:
- Retention rate by months since activation
- Cohort size and activity tracking
- Product-specific retention curves

**Sample Insights**:
- Overall month-2 retention: 56%
- Multi-product users retain at 2x rate vs single-product
- Premium segment shows +18pp retention advantage

![Model Details](screenshots/model_details.png)

## 🧪 Data Quality Framework

**19 automated tests** covering:

✅ **Uniqueness**: Primary key constraints on all fact/dimension tables  
✅ **Referential Integrity**: Foreign key relationships validated  
✅ **Not Null**: Critical fields verified (user_id, transaction_id, dates)  
✅ **Accepted Values**: Status fields, product categories, segments  
✅ **Business Logic**: GMV > 0, dates in valid ranges, retention rates 0-100%

![Test Results](screenshots/test_results.png)

## 🚀 Quick Start

### Prerequisites

```bash
pip install dbt-duckdb
```

### Setup & Run

```bash
# Clone repository
git clone https://github.com/FATIMA-FARMAN/superapp-lifecycle-analytics.git
cd superapp-lifecycle-analytics

# Configure dbt profile (see SETUP.md for details)
cp profiles_template/profiles.yml ~/.dbt/profiles.yml

# Install dependencies
dbt deps

# Load seed data
dbt seed

# Run pipeline
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

See [SETUP.md](SETUP.md) for detailed installation instructions.

## 📚 Documentation

- **[Data Dictionary](DATA_DICTIONARY.md)**: Complete field definitions and business logic
- **[Setup Guide](SETUP.md)**: Step-by-step installation and configuration
- **[Fintech Use Cases](FINTECH_USE_CASES.md)**: How this applies to BNPL and fintech analytics

Interactive documentation available via dbt Docs:
```bash
dbt docs serve
# Navigate to http://localhost:8080
```

## 🛠️ Tech Stack

- **Orchestration**: dbt Core 1.11.2
- **Database**: DuckDB (embedded analytics database)
- **Version Control**: Git + GitHub
- **Documentation**: dbt Docs with auto-generated lineage
- **Testing**: dbt native data quality framework

## 💼 Business Value

✅ **Unified Customer View**: Single source of truth across all product lines  
✅ **Data Quality Automation**: 19 tests preventing bad data from reaching dashboards  
✅ **Self-Service Analytics**: Documented models enabling analyst independence  
✅ **Production-Ready**: Modular architecture supporting 200K+ transactions  
✅ **Scalable Design**: Staging → Marts pattern ready for cloud deployment

## 🎯 Use Cases

### 1. Customer Activation Optimization
Identify friction points in onboarding and measure time-to-first-purchase by segment and product.

### 2. Retention & Churn Analysis
Track cohort health over time, identify at-risk segments, and measure impact of retention initiatives.

### 3. Cross-Product Adoption
Understand multi-product usage journeys and optimize product recommendations.

### 4. Lifetime Value Modeling
Calculate customer LTV by segment, product mix, and activation cohort for CAC payback analysis.

### 5. Product Performance
Compare GMV, frequency, and retention across product lines to inform product strategy.

## 💳 BNPL & Fintech Applications

This project demonstrates analytics patterns directly applicable to Buy Now Pay Later platforms like **Tabby**:

- **Credit Risk Assessment**: Early transaction behavior predicts repayment patterns
- **Installment Tracking**: Cohort analysis models payment plan performance
- **Fraud Detection**: Behavioral anomaly detection via transaction velocity and patterns
- **Merchant Analytics**: Product-level performance tracking for merchant partnerships
- **Customer Segmentation**: Risk-based tiering using multi-product engagement

See [FINTECH_USE_CASES.md](FINTECH_USE_CASES.md) for detailed applications.

## 📁 Project Structure

```
superapp-lifecycle-analytics/
├── models/
│   ├── staging/                    # Raw data standardization
│   │   ├── stg_users.sql
│   │   ├── stg_transactions.sql
│   │   └── stg_events.sql
│   ├── marts/                      # Business logic layer
│   │   ├── dim_users_enhanced.sql
│   │   ├── fct_activation.sql
│   │   ├── fct_transactions_enhanced.sql
│   │   └── fct_retention.sql
│   └── schema.yml                  # Tests and documentation
├── analyses/                       # Ad-hoc analytical queries
├── seeds/                          # CSV source data
├── macros/                         # Custom dbt macros
├── screenshots/                    # Documentation images
├── profiles_template/              # dbt profile configuration
├── dbt_project.yml                # Project configuration
├── SETUP.md                        # Installation guide
├── DATA_DICTIONARY.md              # Field definitions
└── FINTECH_USE_CASES.md            # Industry applications
```

## 📊 Sample Analyses

### Retention Metrics

```sql
-- Monthly retention rates by product and cohort
SELECT 
    product,
    cohort_month,
    months_since_activation,
    cohort_size,
    active_users,
    retention_rate
FROM {{ ref('fct_retention') }}
WHERE months_since_activation <= 12
ORDER BY product, cohort_month, months_since_activation;
```

### Product Performance

```sql
-- GMV and engagement metrics by product line
SELECT 
    product,
    COUNT(DISTINCT user_id) as total_users,
    SUM(amount) as total_gmv,
    SUM(amount) / COUNT(DISTINCT user_id) as gmv_per_user,
    COUNT(*) / COUNT(DISTINCT user_id) as transactions_per_user,
    AVG(amount) as avg_order_value
FROM {{ ref('fct_transactions_enhanced') }}
WHERE status = 'Completed'
GROUP BY product
ORDER BY total_gmv DESC;
```

### Activation Funnel

```sql
-- Conversion rates from signup to first purchase
WITH user_base AS (
    SELECT 
        user_segment,
        COUNT(*) as signups
    FROM {{ ref('stg_users') }}
    GROUP BY user_segment
),
activations AS (
    SELECT 
        u.user_segment,
        COUNT(DISTINCT a.user_id) as activated_users,
        AVG(a.days_to_activate) as avg_days_to_activate
    FROM {{ ref('fct_activation') }} a
    JOIN {{ ref('stg_users') }} u ON a.user_id = u.user_id
    GROUP BY u.user_segment
)
SELECT 
    b.user_segment,
    b.signups,
    COALESCE(a.activated_users, 0) as activated_users,
    ROUND(100.0 * COALESCE(a.activated_users, 0) / b.signups, 2) as activation_rate,
    ROUND(a.avg_days_to_activate, 1) as avg_days_to_activate
FROM user_base b
LEFT JOIN activations a ON b.user_segment = a.user_segment;
```

## 👩‍💻 About

**Fatima Farman**  
*Analytics Engineer | BNPL & Fintech Product Analytics*

- 📍 Based in Karachi, Pakistan | Open to Dubai opportunities
- 💼 3+ years in consumer fintech, HR analytics, and data engineering
- 🎯 Expertise: Customer lifecycle analytics, dbt, SQL, Python, BigQuery, Looker
- 🏆 Certifications: Google Cloud (Data Engineering, Warehousing), dbt Analytics Engineering

📧 **Email**: [your.email@example.com](mailto:your.email@example.com)  
💼 **LinkedIn**: [linkedin.com/in/fatima-farman](https://linkedin.com/in/fatima-farman)  
🌐 **Portfolio**: [github.com/FATIMA-FARMAN](https://github.com/FATIMA-FARMAN)

---

## 📈 Project Evolution

**Development Timeline**: 20 days (intensive sprint)

1. **Days 1-5**: Data modeling and staging layer implementation
2. **Days 6-12**: Marts layer development and business logic
3. **Days 13-17**: Testing framework and data quality automation
4. **Days 18-20**: Documentation, analyses, and portfolio optimization

**Key Learnings**:
- Modular dbt architecture scales much better than monolithic SQL
- Early testing saves hours of debugging downstream
- Clear documentation makes models self-service for stakeholders

---

⭐ **Star this repo** if you find it helpful for your own analytics projects!

Built with ❤️ using dbt + DuckDB | Optimized for fintech applications
