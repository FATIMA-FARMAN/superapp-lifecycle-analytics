import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set random seed for reproducibility
np.random.seed(42)
random.seed(42)

print("🚀 Generating SuperApp synthetic data...")

# Configuration to match README metrics
TARGET_GMV = 68_200_000  # $68.2M
TARGET_TRANSACTIONS = 224_614
NUM_USERS = 50_000

# Product distribution (matching multi-product SuperApp)
PRODUCTS = {
    'bnpl': {'weight': 0.35, 'avg_amount': 450, 'std': 200},
    'food_delivery': {'weight': 0.30, 'avg_amount': 35, 'std': 15},
    'ride_sharing': {'weight': 0.25, 'avg_amount': 18, 'std': 8},
    'gaming': {'weight': 0.10, 'avg_amount': 25, 'std': 12}
}

COUNTRIES = ['UAE', 'KSA', 'EGY', 'KWT', 'PAK', 'IND', 'NGA', 'USA', 'UK']
STATUSES = ['completed', 'pending', 'failed', 'cancelled']
EVENT_TYPES = ['login', 'view', 'click', 'purchase', 'logout', 'signup', 'search']

# Generate Users
print("📊 Generating users...")
users = pd.DataFrame({
    'user_id': range(1, NUM_USERS + 1),
    'name': [f'User_{i}' for i in range(1, NUM_USERS + 1)],
    'age': np.random.randint(18, 65, NUM_USERS),
    'country': np.random.choice(COUNTRIES, NUM_USERS, p=[0.25, 0.20, 0.15, 0.10, 0.10, 0.08, 0.07, 0.03, 0.02]),
    'gender': np.random.choice(['Male', 'Female', 'Other'], NUM_USERS, p=[0.48, 0.50, 0.02])
})

# Generate Transactions
print("💳 Generating transactions...")
transactions = []
transaction_id = 1

# Calculate transactions per product to match target
product_list = list(PRODUCTS.keys())
product_weights = [PRODUCTS[p]['weight'] for p in product_list]

for _ in range(TARGET_TRANSACTIONS):
    product = np.random.choice(product_list, p=product_weights)
    
    # Generate amount with some outliers for realism
    if random.random() < 0.05:  # 5% high-value transactions
        amount = np.random.gamma(4, PRODUCTS[product]['avg_amount'] * 2)
    else:
        amount = max(1, np.random.normal(
            PRODUCTS[product]['avg_amount'],
            PRODUCTS[product]['std']
        ))
    
    # Status distribution: 85% completed, 10% pending, 3% failed, 2% cancelled
    status = np.random.choice(
        STATUSES,
        p=[0.85, 0.10, 0.03, 0.02]
    )
    
    # Only completed transactions contribute to GMV
    if status != 'completed':
        amount = amount * 0.3  # Reduce failed/pending amounts
    
    transactions.append({
        'Transaction_ID': transaction_id,
        'Customer_ID': np.random.randint(1, NUM_USERS + 1),
        'Date': datetime(2023, 1, 1) + timedelta(
            days=random.randint(0, 730)  # 2 years of data
        ),
        'Amount': round(amount, 2),
        'Currency': 'USD',
        'Status': status.capitalize(),
        'Payment_Method': np.random.choice(
            ['Credit Card', 'PayPal', 'Bank Transfer', 'Digital Wallet'],
            p=[0.45, 0.25, 0.20, 0.10]
        ),
        'Product': product
    })
    transaction_id += 1

transactions_df = pd.DataFrame(transactions)

# Adjust to hit exact GMV target
current_gmv = transactions_df[transactions_df['Status'] == 'Completed']['Amount'].sum()
scaling_factor = TARGET_GMV / current_gmv
transactions_df['Amount'] = transactions_df['Amount'] * scaling_factor
transactions_df['Amount'] = transactions_df['Amount'].round(2)

# Generate Events (3-5 events per transaction)
print("📱 Generating user events...")
events = []
event_id = 1

for _, txn in transactions_df.iterrows():
    num_events = random.randint(3, 5)
    txn_date = txn['Date']
    
    for i in range(num_events):
        event_time = txn_date - timedelta(
            hours=random.randint(0, 24),
            minutes=random.randint(0, 59)
        )
        
        events.append({
            'event_id': f'EVT{event_id:06d}',
            'user_id': f'USER{txn["Customer_ID"]:04d}',
            'event_type': np.random.choice(EVENT_TYPES),
            'event_timestamp': event_time
        })
        event_id += 1

events_df = pd.DataFrame(events)

# Save to CSV
print("💾 Saving files...")
users.to_csv('data/raw/users.csv', index=False)
transactions_df.to_csv('data/raw/transactions.csv', index=False)
events_df.to_csv('data/raw/events.csv', index=False)

# Print summary
print("\n✅ Data generation complete!")
print(f"📊 Summary:")
print(f"   Users: {len(users):,}")
print(f"   Transactions: {len(transactions_df):,}")
print(f"   Events: {len(events_df):,}")
print(f"   Total GMV: ${transactions_df[transactions_df['Status'] == 'Completed']['Amount'].sum():,.2f}")
print(f"   Average Transaction: ${transactions_df['Amount'].mean():,.2f}")
print(f"\n📁 Files saved to data/raw/")
print(f"   - users.csv ({len(users):,} rows)")
print(f"   - transactions.csv ({len(transactions_df):,} rows)")
print(f"   - events.csv ({len(events_df):,} rows)")

