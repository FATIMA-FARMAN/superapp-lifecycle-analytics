# 📖 Data Dictionary

## Source Data

### users.csv
- `user_id`: Unique customer identifier
- `signup_date`: Account creation timestamp
- `city`: User location
- `user_segment`: Customer categorization (Premium/Standard)

### transactions.csv
- `transaction_id`: Unique transaction identifier
- `user_id`: Customer reference (FK to users)
- `product`: Product line (BNPL/Food/Ride/Gaming)
- `amount`: Transaction value (USD)
- `transaction_date`: Transaction timestamp
- `status`: Payment status (Completed/Failed/Pending)

### events.csv
- `event_id`: Unique event identifier
- `user_id`: Customer reference (FK to users)
- `event_type`: Action type (Login/Purchase/Browse)
- `event_date`: Event timestamp
- `product`: Associated product line

## Models

### Staging Layer

#### stg_users
Clean, deduplicated user master with standardized date formats.

#### stg_transactions
Standardized transaction records with status validation.

#### stg_events
Clean event stream with product categorization.

### Marts Layer

#### dim_users
**Purpose**: Customer dimension with lifetime metrics

Key Metrics:
- `total_gmv`: Lifetime transaction value
- `transaction_count`: Total transactions
- `products_used_count`: Number of distinct products
- `first_transaction_date`: Activation date
- `last_transaction_date`: Most recent activity
- `days_active`: Tenure since first transaction

#### fct_activation
**Purpose**: First transaction analysis by product

Metrics:
- `days_to_activate`: Time from signup to first purchase
- Activation rate by segment and product

#### fct_transactions
**Purpose**: Complete transaction history with customer context

Includes:
- Transaction sequencing (transaction_number)
- Customer segment at transaction time
- Days since previous transaction
- Product adoption flags

#### fct_retention
**Purpose**: Monthly cohort retention analysis

Dimensions:
- `cohort_month`: First transaction month
- `months_since_activation`: Cohort age
- `retention_rate`: % of cohort still active
- By product line

## Business Metrics

### Key Performance Indicators

1. **GMV (Gross Merchandise Value)**: Total transaction volume
2. **Activation Rate**: % of signups making first purchase
3. **Retention Rate**: % of cohort active in period N
4. **LTV (Lifetime Value)**: Total GMV per customer
5. **Cross-Product Adoption**: % using 2+ products
6. **Time to Activate**: Days from signup to first transaction

### Retention Definition

A user is considered "retained" in month N if they made at least one transaction in that month.
