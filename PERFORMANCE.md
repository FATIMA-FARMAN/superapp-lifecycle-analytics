# Performance Metrics

## Model Sizes
- **dim_users**: 50,000 rows
- **fct_transactions**: 224,614 rows
- **fct_activation**: 108,913 rows
- **fct_retention**: Cohort-based (monthly aggregates)

## Optimization Techniques
1. ✅ Incremental models for large tables (224K+ rows)
2. ✅ Views for staging (always fresh, minimal storage)
3. ✅ Tables for frequently-queried marts
4. ✅ Custom macros for reusable logic
5. ✅ Snapshots for historical tracking

## Build Performance
- Staging layer: < 1 second (views)
- Marts layer: 3-5 seconds (full refresh)
- Incremental: < 1 second (new data only)
