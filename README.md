# 🚀 SuperApp Customer Lifecycle Analytics Platform

[![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-FFF000?style=flat&logo=duckdb&logoColor=black)](https://duckdb.org/)

A production-grade **dbt + DuckDB** analytics engineering project modeling the full customer lifecycle of a MENA-region SuperApp — covering activation, retention, and GMV analytics across multiple product verticals (BNPL, food delivery, ride sharing, gaming).

Built to demonstrate end-to-end analytics engineering capabilities relevant to fintech platforms like Tabby, Tamara, and Careem.

---

## Architecture
```
Raw Data (CSV)  →  Staging  →  Intermediate  →  Marts  →  Analyses/Exposures
     3 sources      3 views     3 views         5 tables    4 analyses
                                                1 snapshot   3 exposures
```

**Tech Stack:** dbt 1.11 · DuckDB · SQL · Git

---

## Data Model

### Sources
| Source | Records | Description |
|--------|---------|-------------|
| `users` | 10 | User profiles across UAE, Saudi Arabia, Egypt, Kuwait |
| `transactions` | 11 | Multi-product transactions (BNPL, food delivery, ride sharing, gaming) |
| `events` | — | User behavioral events (login, view, click, purchase, logout) |

### Model Layers

**Staging** — Clean, typed, and tested source data
- `stg_users` · `stg_transactions` · `stg_events`

**Intermediate** — Business logic aggregations
- `int_user_summary` — Per-user lifetime metrics, product mix, activation status
- `int_transaction_summary` — Daily/monthly/product-level GMV, success rates
- `int_event_summary` — User engagement and activity patterns

**Marts** — Business-ready dimensional models
- `dim_users` — User dimension with lifetime GMV, tenure, customer tier, recency status
- `fct_transactions` — Transaction fact table enriched with user context and sequence numbers
- `fct_transactions_incremental` — Incremental materialization pattern for production scalability
- `fct_activation` — Time-to-activate by user × product, measuring onboarding velocity
- `fct_retention` — Cohort-based monthly retention with GMV tracking

**Snapshot**
- `user_segment_snapshot` — SCD Type 2 tracking of user segment and country changes

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Avg Lifetime GMV per User | $265.17 |
| Total Completed GMV | $2,386.50 |
| BNPL GMV (largest vertical) | $2,000.00 (83.8%) |
| Markets Covered | 4 (UAE, KSA, Egypt, Kuwait) |
| Product Verticals | 4 (BNPL, Food Delivery, Ride Sharing, Gaming) |

---

## Testing & Quality

**33 data tests** covering:
- Primary key uniqueness and not-null constraints
- Referential integrity (transactions → users, events → users)
- Accepted values validation on status, product, country, segment, event type
- All tests passing ✅

---

## Analytics & Exposures

**Analyses** (ad-hoc business queries):
- `activation_funnel` — Registration-to-first-transaction conversion
- `cohort_retention_advanced` — Month-over-month cohort retention curves
- `retention_metrics` — Retention rate calculations by product
- `product_metrics` — Cross-product performance comparison

**Exposures** (downstream consumers):
- 📊 Retention Dashboard
- 📊 Activation Funnel
- 📊 GMV Analytics

---

## Project Structure
```
superapp-lifecycle-analytics/
├── data/raw/                    # Source CSV files
├── models/
│   ├── staging/                 # Source cleaning & typing
│   ├── intermediate/            # Business logic layer
│   └── marts/                   # Dimensional models
├── snapshots/                   # SCD Type 2 tracking
├── analyses/                    # Ad-hoc analytics queries
├── macros/                      # Custom dbt macros
├── tests/                       # Data quality tests
└── dbt_project.yml
```

---

## Fintech Relevance

This project directly mirrors the analytics challenges at BNPL and SuperApp companies:

- **Multi-product lifecycle tracking** — Same user across BNPL, payments, delivery
- **Cohort retention analysis** — Critical for subscription and repeat-purchase models
- **Activation funnel metrics** — Time-to-first-transaction drives product growth
- **GMV analytics by vertical** — Revenue attribution across business lines
- **MENA market segmentation** — Regional user behavior patterns
- **Incremental materialization** — Production-ready pattern for high-volume transaction data
- **SCD tracking** — Capturing user segment migrations over time

---

## Quick Start
```bash
# Prerequisites: Python 3.10+, dbt-duckdb
pip install dbt-duckdb

# Clone and run
git clone https://github.com/FATIMA-FARMAN/superapp-lifecycle-analytics.git
cd superapp-lifecycle-analytics
dbt run --full-refresh
dbt test
dbt snapshot
dbt docs generate && dbt docs serve
```

---

## DAG (Lineage Graph)
![Data Lineage](screenshots/lineage_graph.png)

---


 Analytics Engineer | People Data Analyst
- Specializing in fintech analytics, dbt, and cloud data platforms
- [LinkedIn](https://linkedin.com/in/your-profile) · [GitHub](https://github.com/FATIMA-FARMAN)

## 👩‍💻 About

**Fatima Farman**  

 Analytics Engineer | People Data Analyst
- Specializing in fintech analytics, dbt, and cloud data platforms
- [LinkedIn](https://www.linkedin.com/in/fatima-farman-b524a3204/) · [GitHub](https://github.com/FATIMA-FARMAN)
- 3+ years in consumer fintech & BNPL
- Expertise: Customer lifecycle analytics, A/B testing, growth optimization
- Tech: SQL, Python, dbt, BigQuery, Tableau


---

⭐ **Star this repo** if you find it helpful!

Built with ❤️ using dbt + DuckDB
