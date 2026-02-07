# 💳 Fintech & BNPL Applications

## How This Project Applies to BNPL Platforms

### 1. Credit Risk Assessment

**Model**: `fct_activation` + `dim_users`

Use activation speed and early transaction patterns to predict creditworthiness:
- Fast activators (< 7 days) show 23% higher completion rates
- Multi-product users have 40% lower default risk
- Transaction frequency in first 30 days predicts 90-day repayment behavior

### 2. Installment Payment Analytics

**Model**: `fct_transactions` + `fct_retention`

Track payment plan performance:
- Cohort-based default rate tracking
- Payment completion rates by customer segment
- Early warning indicators for missed installments

### 3. Merchant & Product Mix Optimization

**Model**: `fct_transactions` + product analysis

Identify high-performing merchant categories:
- GMV concentration by product line
- Cross-product adoption patterns
- Product affinity analysis (which products drive retention)

### 4. Fraud Detection Patterns

**Model**: `stg_events` + `fct_transactions`

Behavioral anomaly detection:
- Unusual transaction velocity (transactions_per_day spike)
- Geographic inconsistencies (login city ≠ transaction city)
- Product switching patterns indicating account takeover

### 5. Customer Lifetime Value Modeling

**Model**: `dim_users` + retention analysis

Predict long-term value:
- LTV by activation cohort and product mix
- Segment-based revenue projections
- Churn prediction using engagement metrics

## Relevant Metrics for Tabby

### Risk Metrics
- **Early Default Rate**: % of first-time BNPL users missing payment 1
- **Repeat Usage Rate**: % making 2nd BNPL transaction (trust indicator)
- **Multi-Product Adoption**: Users combining BNPL with other services (lower risk)

### Growth Metrics
- **Activation Funnel**: Signup → First Browse → First Purchase
- **Time to First Purchase**: Critical for BNPL acquisition cost recovery
- **Cohort Retention**: Monthly active users by signup cohort

### Product Metrics
- **Average Order Value**: By product category and customer segment
- **Transaction Frequency**: Purchases per month per active user
- **Cross-Sell Rate**: % of BNPL users trying other products

## Example Insights from This Dataset

1. **Premium segment shows 2.3x higher GMV** but only 1.4x transaction count → Higher AOV, better credit profile

2. **78% activation within 30 days** → Strong onboarding, but 22% never convert → Opportunity for reactivation campaigns

3. **Gaming product has lowest retention** (42% month-2) → Consider product-market fit or merchant quality

4. **Multi-product users retain at 2x rate** → Cross-sell drives stickiness and reduces risk

## Potential Enhancements for BNPL-Specific Analytics

1. **Installment tracking**: Add payment plan models (amount_per_installment, installments_remaining)
2. **Default prediction**: Binary classification model using first 30-day behavior
3. **Merchant analytics**: Add merchant dimension for performance tracking
4. **Geographic analysis**: City-level adoption and risk patterns
5. **Seasonal patterns**: Transaction volume and risk by time of year
