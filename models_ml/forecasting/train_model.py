"""
Event Forecasting Model
Predicts future event volumes using historical patterns.
"""

import duckdb
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import pickle
from pathlib import Path

# Setup
np.random.seed(42)
output_dir = Path('models_ml/forecasting/outputs')
output_dir.mkdir(parents=True, exist_ok=True)

print("=" * 70)
print("EVENT FORECASTING MODEL - RANDOM FOREST")
print("=" * 70)

# 1. Load data
print("\n📊 Loading data from DuckDB...")
conn = duckdb.connect('./dev.duckdb', read_only=True)

# Get user-level aggregated features
query = """
SELECT 
    user_id,
    total_events,
    events_last_30d,
    events_last_7d,
    unique_event_types,
    login_events,
    view_events,
    click_events,
    purchase_events,
    days_with_events,
    days_since_last_event
FROM main.customer_features_for_ml
"""

df = conn.execute(query).df()
conn.close()

print(f"✅ Loaded {len(df)} users")

# 2. Create forecasting features and target
print("\n🔧 Creating forecasting features...")

# Target: predict total_events (future activity indicator)
# Features: recent activity patterns
feature_cols = [
    'events_last_30d', 'events_last_7d', 'unique_event_types',
    'login_events', 'view_events', 'click_events', 'purchase_events',
    'days_with_events', 'days_since_last_event'
]

X = df[feature_cols]
y = df['total_events']  # Predict lifetime events based on recent patterns

print(f"   Features: {len(feature_cols)}")
print(f"   Target: total_events (range: {y.min():.0f} to {y.max():.0f})")

# 3. Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"\n📈 Train-test split:")
print(f"   Training set: {len(X_train)} samples")
print(f"   Test set: {len(X_test)} samples")

# 4. Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 5. Train Random Forest model
print("\n🤖 Training Random Forest Regressor...")
model = RandomForestRegressor(
    n_estimators=100,
    max_depth=10,
    min_samples_split=5,
    random_state=42,
    n_jobs=-1
)

model.fit(X_train_scaled, y_train)
print("✅ Model trained successfully!")

# 6. Evaluate model
print("\n📊 Model evaluation:")
y_pred_train = model.predict(X_train_scaled)
y_pred_test = model.predict(X_test_scaled)

# Training metrics
train_mae = mean_absolute_error(y_train, y_pred_train)
train_rmse = np.sqrt(mean_squared_error(y_train, y_pred_train))
train_r2 = r2_score(y_train, y_pred_train)

# Test metrics
test_mae = mean_absolute_error(y_test, y_pred_test)
test_rmse = np.sqrt(mean_squared_error(y_test, y_pred_test))
test_r2 = r2_score(y_test, y_pred_test)

print("\nTraining Set:")
print(f"   MAE:  {train_mae:.2f} events")
print(f"   RMSE: {train_rmse:.2f} events")
print(f"   R²:   {train_r2:.4f}")

print("\nTest Set:")
print(f"   MAE:  {test_mae:.2f} events")
print(f"   RMSE: {test_rmse:.2f} events")
print(f"   R²:   {test_r2:.4f}")

# Sample predictions
print("\n🔍 Sample predictions (first 5 test samples):")
print(f"{'Actual':>8} {'Predicted':>10} {'Error':>8}")
for i in range(min(5, len(y_test))):
    actual = y_test.iloc[i]
    predicted = y_pred_test[i]
    error = actual - predicted
    print(f"{actual:8.1f} {predicted:10.1f} {error:8.1f}")

# 7. Feature importance
print("\n🎯 Feature Importance:")
feature_importance = pd.DataFrame({
    'feature': feature_cols,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

print(feature_importance.to_string(index=False))

# 8. Save artifacts
print("\n💾 Saving model artifacts...")

# Save model
with open(output_dir / 'rf_forecast_model.pkl', 'wb') as f:
    pickle.dump(model, f)

# Save scaler
with open(output_dir / 'scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

# Save feature names
with open(output_dir / 'feature_names.txt', 'w') as f:
    f.write('\n'.join(feature_cols))

# Save feature importance
feature_importance.to_csv(output_dir / 'feature_importance.csv', index=False)

# Save metrics
metrics = {
    'train_samples': len(X_train),
    'test_samples': len(X_test),
    'train_mae': float(train_mae),
    'train_rmse': float(train_rmse),
    'train_r2': float(train_r2),
    'test_mae': float(test_mae),
    'test_rmse': float(test_rmse),
    'test_r2': float(test_r2),
    'target_range': {'min': float(y.min()), 'max': float(y.max())}
}

import json
with open(output_dir / 'metrics.json', 'w') as f:
    json.dump(metrics, f, indent=2)

print(f"✅ Saved to {output_dir}/")
print(f"   - rf_forecast_model.pkl")
print(f"   - scaler.pkl")
print(f"   - feature_names.txt")
print(f"   - feature_importance.csv")
print(f"   - metrics.json")

print("\n" + "=" * 70)
print("✅ EVENT FORECASTING MODEL COMPLETE!")
print("=" * 70)
