import duckdb

print("=" * 60)
print("ML FEATURES SUMMARY")
print("=" * 60)

conn = duckdb.connect('./dev.duckdb', read_only=True)

print("\n✅ Database: ./dev.duckdb")
print("📊 Table: main.customer_features_for_ml")

# Get count
count = conn.execute('SELECT COUNT(*) FROM main.customer_features_for_ml').fetchone()[0]
print(f"\nTotal users: {count}")

# Get columns
cols = conn.execute('DESCRIBE main.customer_features_for_ml').fetchall()
print(f"\nTotal features: {len(cols)}")
print("\nAll columns:")
for i, col in enumerate(cols, 1):
    print(f"  {i}. {col[0]}: {col[1]}")

# Sample data
print("\n🔍 Sample data (first 3 users):")
sample = conn.execute('SELECT user_id, total_events, events_last_30d, events_last_7d, is_inactive FROM main.customer_features_for_ml LIMIT 3').fetchall()
for row in sample:
    print(f"\n  User: {row[0]}")
    print(f"    Total events: {row[1]}")
    print(f"    Events (30d): {row[2]}")
    print(f"    Events (7d): {row[3]}")
    print(f"    Inactive?: {'Yes' if row[4] else 'No'}")

# Statistics
print("\n📈 Dataset statistics:")
stats = conn.execute("""
    SELECT
        COUNT(*) as total_users,
        AVG(total_events) as avg_events,
        AVG(events_last_30d) as avg_events_30d,
        AVG(events_last_7d) as avg_events_7d,
        SUM(is_inactive) as inactive_users,
        ROUND(SUM(is_inactive)::FLOAT / COUNT(*) * 100, 2) as inactive_rate_pct
    FROM main.customer_features_for_ml
""").fetchone()

print(f"  Total users: {stats[0]}")
print(f"  Avg total events: {stats[1]:.1f}")
print(f"  Avg events (30d): {stats[2]:.1f}")
print(f"  Avg events (7d): {stats[3]:.1f}")
print(f"  Inactive users: {stats[4]}")
print(f"  Inactive rate: {stats[5]}%")

conn.close()
print("\n" + "=" * 60)
print("✅ Phase 1 Complete: ML Features Ready!")
print("=" * 60)
print("\n🎯 Next: Phase 2 - Build ML Models")
print("   - Churn/Inactivity prediction (XGBoost)")
print("   - Customer segmentation (K-Means)")
print("   - Event forecasting")
