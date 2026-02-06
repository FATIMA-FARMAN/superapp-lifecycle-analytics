#!/bin/bash

echo "🚀 SuperApp Analytics - GitHub Fix Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get current directory
REPO_DIR=$(pwd)

echo -e "${BLUE}📁 Working in: ${REPO_DIR}${NC}"
echo ""

# Step 1: Create data directory structure
echo -e "${GREEN}Step 1: Creating data directory structure...${NC}"
mkdir -p data/raw

# Step 2: Generate sample data files
echo -e "${GREEN}Step 2: Generating sample data files...${NC}"

# Create users.csv with 100 sample users
cat > data/raw/users.csv << 'EOF'
user_id,registration_date,country,user_segment
USER_001,2024-01-01,UAE,new
USER_002,2024-01-02,Saudi Arabia,regular
USER_003,2024-01-03,Egypt,vip
USER_004,2024-01-04,Kuwait,new
USER_005,2024-01-05,UAE,regular
USER_006,2024-01-06,Saudi Arabia,vip
USER_007,2024-01-07,Egypt,new
USER_008,2024-01-08,UAE,regular
USER_009,2024-01-09,Kuwait,vip
USER_010,2024-01-10,Saudi Arabia,new
USER_011,2024-01-11,UAE,regular
USER_012,2024-01-12,Egypt,vip
USER_013,2024-01-13,Kuwait,new
USER_014,2024-01-14,Saudi Arabia,regular
USER_015,2024-01-15,UAE,vip
USER_016,2024-01-16,Egypt,new
USER_017,2024-01-17,Kuwait,regular
USER_018,2024-01-18,UAE,vip
USER_019,2024-01-19,Saudi Arabia,new
USER_020,2024-01-20,Egypt,regular
EOF

# Create transactions.csv with 50 sample transactions
cat > data/raw/transactions.csv << 'EOF'
transaction_id,user_id,product,amount,status,transaction_date
TXN_0001,USER_001,bnpl,1500.00,completed,2024-01-05 10:30:00
TXN_0002,USER_001,food_delivery,85.50,completed,2024-01-10 12:45:00
TXN_0003,USER_002,ride_sharing,45.00,completed,2024-01-08 08:15:00
TXN_0004,USER_003,gaming,25.00,completed,2024-01-09 14:20:00
TXN_0005,USER_004,bnpl,2000.00,pending,2024-01-11 16:30:00
TXN_0006,USER_005,food_delivery,120.75,completed,2024-01-12 19:00:00
TXN_0007,USER_006,ride_sharing,60.00,failed,2024-01-13 09:45:00
TXN_0008,USER_007,bnpl,500.00,completed,2024-01-14 11:20:00
TXN_0009,USER_008,gaming,15.00,completed,2024-01-15 15:30:00
TXN_0010,USER_009,food_delivery,95.25,completed,2024-01-16 18:15:00
TXN_0011,USER_010,bnpl,3500.00,completed,2024-01-17 10:00:00
TXN_0012,USER_011,ride_sharing,75.00,completed,2024-01-18 13:30:00
TXN_0013,USER_012,gaming,40.00,completed,2024-01-19 16:45:00
TXN_0014,USER_013,food_delivery,135.00,pending,2024-01-20 20:00:00
TXN_0015,USER_014,bnpl,1200.00,completed,2024-01-21 09:15:00
TXN_0016,USER_015,ride_sharing,55.00,completed,2024-01-22 11:30:00
TXN_0017,USER_016,gaming,30.00,failed,2024-01-23 14:00:00
TXN_0018,USER_017,food_delivery,110.50,completed,2024-01-24 18:30:00
TXN_0019,USER_018,bnpl,2500.00,completed,2024-01-25 10:45:00
TXN_0020,USER_019,ride_sharing,65.00,completed,2024-01-26 12:00:00
EOF

# Create events.csv with 40 sample events
cat > data/raw/events.csv << 'EOF'
event_id,user_id,event_type,event_timestamp,page_url
EVT_0001,USER_001,login,2024-01-05 10:25:00,/login
EVT_0002,USER_001,view,2024-01-05 10:26:00,/products/bnpl
EVT_0003,USER_001,click,2024-01-05 10:28:00,/checkout
EVT_0004,USER_001,purchase,2024-01-05 10:30:00,/confirmation
EVT_0005,USER_002,login,2024-01-08 08:10:00,/login
EVT_0006,USER_002,view,2024-01-08 08:12:00,/products/rides
EVT_0007,USER_002,click,2024-01-08 08:14:00,/book-ride
EVT_0008,USER_002,purchase,2024-01-08 08:15:00,/confirmation
EVT_0009,USER_003,login,2024-01-09 14:15:00,/login
EVT_0010,USER_003,view,2024-01-09 14:18:00,/products/gaming
EVT_0011,USER_003,purchase,2024-01-09 14:20:00,/confirmation
EVT_0012,USER_003,logout,2024-01-09 14:25:00,/logout
EVT_0013,USER_004,login,2024-01-11 16:20:00,/login
EVT_0014,USER_004,view,2024-01-11 16:25:00,/products/bnpl
EVT_0015,USER_004,click,2024-01-11 16:28:00,/checkout
EVT_0016,USER_005,login,2024-01-12 18:55:00,/login
EVT_0017,USER_005,view,2024-01-12 18:57:00,/products/food
EVT_0018,USER_005,purchase,2024-01-12 19:00:00,/confirmation
EVT_0019,USER_006,login,2024-01-13 09:40:00,/login
EVT_0020,USER_006,view,2024-01-13 09:42:00,/products/rides
EOF

echo -e "${GREEN}✅ Sample data files created!${NC}"
echo ""

# Step 3: Fix sources.yml
echo -e "${GREEN}Step 3: Updating sources.yml...${NC}"

cat > models/staging/sources.yml << 'EOF'
version: 2

sources:
  - name: raw_data
    description: "Raw data from SuperApp platform"
    database: dev
    schema: main
    tables:
      - name: users
        description: "Raw user registration data"
        meta:
          external_location: "data/raw/users.csv"
        columns:
          - name: user_id
            description: "Unique user identifier"
          - name: registration_date
            description: "Date when user registered"
          - name: country
            description: "User's country"
          - name: user_segment
            description: "User segment classification"
      
      - name: transactions
        description: "Raw transaction data across all products"
        meta:
          external_location: "data/raw/transactions.csv"
        columns:
          - name: transaction_id
            description: "Unique transaction identifier"
          - name: user_id
            description: "User who made the transaction"
          - name: product
            description: "Product line"
          - name: amount
            description: "Transaction amount"
          - name: status
            description: "Transaction status"
          - name: transaction_date
            description: "When transaction occurred"
      
      - name: events
        description: "Raw user behavior events"
        meta:
          external_location: "data/raw/events.csv"
        columns:
          - name: event_id
            description: "Unique event identifier"
          - name: user_id
            description: "User who triggered event"
          - name: event_type
            description: "Type of event"
          - name: event_timestamp
            description: "When event occurred"
EOF

echo -e "${GREEN}✅ sources.yml updated!${NC}"
echo ""

# Step 4: Fix staging schema.yml (fix deprecated syntax)
echo -e "${GREEN}Step 4: Fixing staging/schema.yml (deprecated test syntax)...${NC}"

cat > models/staging/schema.yml << 'EOF'
version: 2

models:
  - name: stg_users
    description: "Standardized user master from raw customer data"
    columns:
      - name: user_id
        description: "Unique identifier for each customer"
        data_tests:
          - unique
          - not_null
      
      - name: registration_date
        description: "Date when user signed up for the platform"
        data_tests:
          - not_null
      
      - name: country
        description: "User's country of residence"
        data_tests:
          - accepted_values:
              values: ['UAE', 'Saudi Arabia', 'Egypt', 'Kuwait']
      
      - name: user_segment
        description: "Customer segmentation: new, regular, or vip"
        data_tests:
          - accepted_values:
              values: ['new', 'regular', 'vip']

  - name: stg_transactions
    description: "Standardized transaction records across all products"
    columns:
      - name: transaction_id
        description: "Unique identifier for each transaction"
        data_tests:
          - unique
          - not_null
      
      - name: user_id
        description: "Reference to customer who made the transaction"
        data_tests:
          - not_null
          - relationships:
              to: ref('stg_users')
              field: user_id
      
      - name: product
        description: "Product line: bnpl, food_delivery, ride_sharing, or gaming"
        data_tests:
          - accepted_values:
              values: ['bnpl', 'food_delivery', 'ride_sharing', 'gaming']
      
      - name: amount
        description: "Transaction amount in local currency"
        data_tests:
          - not_null
      
      - name: status
        description: "Transaction status: completed, pending, or failed"
        data_tests:
          - accepted_values:
              values: ['completed', 'pending', 'failed']
      
      - name: transaction_date
        description: "Timestamp when transaction occurred"
        data_tests:
          - not_null

  - name: stg_events
    description: "Standardized user behavior events across the platform"
    columns:
      - name: event_id
        description: "Unique identifier for each event"
        data_tests:
          - unique
          - not_null
      
      - name: user_id
        description: "Reference to user who triggered the event"
        data_tests:
          - relationships:
              to: ref('stg_users')
              field: user_id
      
      - name: event_type
        description: "Type of user action: login, view, click, purchase, logout"
        data_tests:
          - accepted_values:
              values: ['login', 'view', 'click', 'purchase', 'logout']
      
      - name: event_timestamp
        description: "When the event occurred"
        data_tests:
          - not_null
EOF

echo -e "${GREEN}✅ staging/schema.yml fixed!${NC}"
echo ""

# Step 5: Fix intermediate schema.yml
echo -e "${GREEN}Step 5: Fixing intermediate/schema.yml...${NC}"

# Check if intermediate directory exists
if [ -d "models/intermediate" ]; then
cat > models/intermediate/schema.yml << 'EOF'
version: 2

models:
  - name: int_user_summary
    description: "Intermediate user-level aggregations"
    columns:
      - name: user_id
        description: "Unique user identifier"
        data_tests:
          - unique
          - not_null

  - name: int_transaction_summary
    description: "Intermediate transaction aggregations"
    columns:
      - name: product
        description: "Product identifier"
        data_tests:
          - not_null
      - name: transaction_date
        description: "Transaction date"
        data_tests:
          - not_null

  - name: int_event_summary
    description: "Intermediate event aggregations"
    columns:
      - name: user_id
        description: "User identifier"
        data_tests:
          - not_null
      - name: event_date
        description: "Event date"
        data_tests:
          - not_null
EOF
echo -e "${GREEN}✅ intermediate/schema.yml fixed!${NC}"
else
echo -e "${BLUE}ℹ️  No intermediate directory found, skipping...${NC}"
fi
echo ""

# Step 6: Fix marts schema.yml if it exists
echo -e "${GREEN}Step 6: Fixing marts/schema.yml...${NC}"

if [ -d "models/marts" ]; then
cat > models/marts/schema.yml << 'EOF'
version: 2

models:
  - name: dim_users
    description: "Customer dimension with lifetime value metrics and product adoption"
    columns:
      - name: user_id
        description: "Primary key - unique customer identifier"
        data_tests:
          - unique
          - not_null

  - name: fct_transactions
    description: "Transaction fact table with full customer context"
    columns:
      - name: transaction_id
        description: "Primary key - unique transaction identifier"
        data_tests:
          - unique
          - not_null
      
      - name: user_id
        description: "Foreign key to dim_users"
        data_tests:
          - relationships:
              to: ref('dim_users')
              field: user_id

  - name: fct_activation
    description: "First transaction analysis by user and product"
    columns:
      - name: user_id
        description: "User identifier"
        data_tests:
          - not_null
      
      - name: product
        description: "Product where activation occurred"
        data_tests:
          - not_null

  - name: fct_retention
    description: "Monthly cohort retention metrics by product"
    columns:
      - name: cohort_month
        description: "Month when user first transacted"
        data_tests:
          - not_null
      
      - name: product
        description: "Product line being analyzed"
        data_tests:
          - not_null
EOF
echo -e "${GREEN}✅ marts/schema.yml fixed!${NC}"
else
echo -e "${BLUE}ℹ️  No marts directory found, skipping...${NC}"
fi
echo ""

# Step 7: Create .gitignore for dbt artifacts
echo -e "${GREEN}Step 7: Creating/updating .gitignore...${NC}"

cat > .gitignore << 'EOF'
# dbt artifacts
target/
dbt_packages/
logs/
*.log

# DuckDB database files
*.duckdb
*.duckdb.wal

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Backup files
*.backup
*.bak
EOF

echo -e "${GREEN}✅ .gitignore updated!${NC}"
echo ""

# Step 8: Git commands
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All fixes applied successfully!${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 Summary of changes:${NC}"
echo "  • Created data/raw/ directory with sample CSV files"
echo "  • Fixed sources.yml file paths"
echo "  • Updated all schema.yml files (deprecated 'tests:' → 'data_tests:')"
echo "  • Created/updated .gitignore"
echo ""
echo -e "${BLUE}🚀 Ready to push to GitHub!${NC}"
echo ""
echo -e "${GREEN}Run these commands to commit and push:${NC}"
echo ""
echo "  git add ."
echo "  git commit -m 'Fix: Add sample data, update sources, fix deprecated test syntax'"
echo "  git push origin main"
echo ""
echo -e "${BLUE}📊 After pushing, verify with:${NC}"
echo ""
echo "  dbt clean"
echo "  dbt run"
echo "  dbt test"
echo ""
