"""
Churn/Inactivity Prediction Model
Predicts which users are likely to become inactive based on their engagement patterns.
"""

import duckdb
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import xgboost as xgb
import matplotlib.pyplot as plt
import seaborn as sns
import pickle
from pathlib import Path

# Setup
np.random.seed(42)
output_dir = Path('models_ml/churn_prediction/outputs')
output_dir.mkdir(parents=True, exist_ok=True)

print("=" * 70)
print("CHURN PREDICTION MODEL - XGBOOST")
print("=" * 70)

# 1. Load data
print("\n📊 Loading data from DuckDB...")
conn = duckdb.connect('./dev.duckdb', read_only=True)

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
    days_since_last_event,
    is_inactive as target
FROM main.customer_features_for_ml
"""

df = conn.execute(query).df()
conn.close()

print(f"✅ Loaded {len(df)} users")
print(f"   Original churn rate: {df['target'].mean():.1%}")

# 2. Create synthetic variation for demonstration
# In production, you'd use real historical data with both active and inactive users
print("\n🔧 Creating synthetic labels for demonstration...")
print("   (In production, use real historical data with both classes)")

# Create labels based on engagement patterns
# Higher engagement = lower chance of churn
df['engagement_score'] = (
    df['total_events'] * 0.3 +
    df['days_with_events'] * 0.3 +
    (100 - df['days_since_last_event']) * 0.4
)

# Label bottom 40% as churned, top 60% as active
threshold = df['engagement_score'].quantile(0.40)
df['target'] = (df['engagement_score'] <= threshold).astype(int)

print(f"✅ Synthetic churn rate: {df['target'].mean():.1%}")
print(f"   Active users: {(df['target'] == 0).sum()}")
print(f"   Churned users: {(df['target'] == 1).sum()}")

# 3. Prepare features
print("\n🔧 Preparing features...")
feature_cols = [col for col in df.columns if col not in ['user_id', 'target', 'engagement_score']]
X = df[feature_cols]
y = df['target']

print(f"   Feature columns: {len(feature_cols)}")

# 4. Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"\n📈 Train-test split:")
print(f"   Training set: {len(X_train)} samples ({(y_train==1).sum()} churned)")
print(f"   Test set: {len(X_test)} samples ({(y_test==1).sum()} churned)")

# 5. Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 6. Train XGBoost model
print("\n🤖 Training XGBoost model...")
model = xgb.XGBClassifier(
    max_depth=5,
    learning_rate=0.1,
    n_estimators=100,
    objective='binary:logistic',
    random_state=42,
    eval_metric='logloss'
)

model.fit(
    X_train_scaled, y_train,
    eval_set=[(X_test_scaled, y_test)],
    verbose=False
)

print("✅ Model trained successfully!")

# 7. Evaluate model
print("\n📊 Model evaluation:")
y_pred = model.predict(X_test_scaled)
y_pred_proba = model.predict_proba(X_test_scaled)[:, 1]

print("\nClassification Report:")
print(classification_report(y_test, y_pred, target_names=['Active', 'Churned']))

# Calculate metrics
auc = roc_auc_score(y_test, y_pred_proba)
print(f"\nAUC-ROC Score: {auc:.4f}")

# Confusion matrix
cm = confusion_matrix(y_test, y_pred)
print(f"\nConfusion Matrix:")
print(f"                Predicted")
print(f"                Active  Churned")
print(f"Actual Active   {cm[0][0]:6d}  {cm[0][1]:7d}")
print(f"       Churned  {cm[1][0]:6d}  {cm[1][1]:7d}")

# 8. Feature importance
print("\n🎯 Top 10 Most Important Features:")
feature_importance = pd.DataFrame({
    'feature': feature_cols,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

print(feature_importance.head(10).to_string(index=False))

# 9. Save artifacts
print("\n💾 Saving model artifacts...")

# Save model
with open(output_dir / 'xgboost_churn_model.pkl', 'wb') as f:
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
    'churn_rate': float(df['target'].mean()),
    'auc_roc': float(auc),
    'accuracy': float((y_pred == y_test).mean()),
    'note': 'Synthetic labels for demonstration - use real historical data in production'
}

import json
with open(output_dir / 'metrics.json', 'w') as f:
    json.dump(metrics, f, indent=2)

print(f"✅ Saved to {output_dir}/")
print(f"   - xgboost_churn_model.pkl (model)")
print(f"   - scaler.pkl (feature scaler)")
print(f"   - feature_names.txt")
print(f"   - feature_importance.csv")
print(f"   - metrics.json")

print("\n" + "=" * 70)
print("✅ CHURN PREDICTION MODEL COMPLETE!")
print("=" * 70)
print("\n💡 Next: Create prediction endpoint (FastAPI)")
