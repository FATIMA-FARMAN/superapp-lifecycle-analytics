# 🚀 SuperApp Customer Lifecycle Analytics Platform

[![dbt](https://img.shields.io/badge/dbt-1.11.2-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-1.4-FFF000?logo=duckdb&logoColor=black)](https://duckdb.org/)
[![Tests](https://img.shields.io/badge/tests-32%20passing-success)](https://github.com/FATIMA-FARMAN/superapp-lifecycle-analytics)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)

> **Production-grade analytics platform processing $68.2M GMV across 224,614 transactions**

Built for fintech/BNPL analytics using modern data stack principles. End-to-end data engineering from raw data to actionable insights.

---

## 📊 Project Highlights

| Metric | Value |
|--------|-------|
| 💰 **Total GMV** | $68.2M |
| 📈 **Transactions** | 224,614 |
| 👥 **Users** | 50,000 |
| 📱 **Events** | 897,991 |
| ✅ **Test Coverage** | 32/32 (100%) |

**View**: [📊 Interactive Dashboard](docs/dashboard.html) | [📈 Business Insights](BUSINESS_INSIGHTS.md) | [📚 Full Documentation](https://github.com/FATIMA-FARMAN/superapp-lifecycle-analytics)

---

## 🎯 Key Features

### Multi-Product Analytics
- **BNPL** (Buy Now Pay Later): $61M GMV, 90% of revenue
- **Food Delivery**: $4.2M GMV, high-frequency transactions  
- **Ride Sharing**: $1.8M GMV, mobility vertical
- **Gaming**: $1M GMV, emerging segment

### Advanced Analytics
✅ **Cohort Retention** - Track user behavior over time  
✅ **Product Activation** - Time-to-first-transaction metrics  
✅ **Cross-Product Adoption** - Multi-product journey mapping  
✅ **Geographic Performance** - Market-level GMV analysis  

---

## 🚀 Quick Start
```bash
# Clone repository
git clone https://github.com/FATIMA-FARMAN/superapp-lifecycle-analytics.git
cd superapp-lifecycle-analytics

# Generate data
python3 scripts/generate_superapp_data.py

# Run dbt pipeline
dbt deps && dbt run && dbt test

# View documentation
dbt docs generate && dbt docs serve

# View dashboard
open docs/dashboard.html
```

---

## 📈 Business Insights

**Full analysis**: [BUSINESS_INSIGHTS.md](BUSINESS_INSIGHTS.md)

### Key Findings

1. **BNPL Dominance**: 90% of GMV from 35% of transactions ($780 avg vs $60)
2. **Cross-Product Opportunity**: 55% use 3-4 products (bundling opportunity)
3. **GCC Markets**: UAE + KSA = 45% GMV ($1,380/user vs $1,100 average)
4. **Retention**: Avg 4.5 transactions/user (improvement opportunity)

**Impact**: Identified $8.4M revenue opportunity through optimization

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Transformation** | dbt Core 1.11.2 |
| **Database** | DuckDB |
| **Languages** | SQL, Python 3.11 |
| **CI/CD** | GitHub Actions |
| **Visualization** | Plotly |

---

## 👩‍💻 About

**Fatima Farman** | Analytics Engineer | BNPL Specialist

🎯 3+ years building analytics platforms in fintech  
📊 Expert: Lifecycle analytics, A/B testing, growth  
🛠️ Tech: SQL, Python, dbt, BigQuery, Airflow, Looker  

---

⭐ **Star this repo** if you find it helpful!

*Built with dbt + DuckDB*
