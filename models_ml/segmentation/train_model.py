"""
Customer Segmentation Model
Groups customers into behavioral segments using K-Means clustering.
"""

import duckdb
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, davies_bouldin_score
import matplotlib.pyplot as plt
import seaborn as sns
import pickle
from pathlib import Path

# Setup
np.random.seed(42)
output_dir = Path('models_ml/segmentation/outputs')
output_dir.mkdir(parents=True, exist_ok=True)

print("=" * 70)
print("CUSTOMER SEGMENTATION MODEL - K-MEANS")
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
    days_since_last_event
FROM main.customer_features_for_ml
"""

df = conn.execute(query).df()
conn.close()

print(f"✅ Loaded {len(df)} users")
print(f"   Features: {len(df.columns) - 1}")

# 2. Prepare features
print("\n🔧 Preparing features for clustering...")
feature_cols = [col for col in df.columns if col != 'user_id']
X = df[feature_cols].values

# 3. Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 4. Find optimal number of clusters
print("\n🔍 Finding optimal number of clusters...")
inertias = []
silhouette_scores = []
K_range = range(2, 8)

for k in K_range:
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    kmeans.fit(X_scaled)
    inertias.append(kmeans.inertia_)
    silhouette_scores.append(silhouette_score(X_scaled, kmeans.labels_))
    print(f"   K={k}: Silhouette={silhouette_scores[-1]:.3f}")

# Choose k=4 as a good balance
optimal_k = 4
print(f"\n✅ Selected K={optimal_k} clusters")

# 5. Train final model
print(f"\n🤖 Training K-Means with {optimal_k} clusters...")
kmeans = KMeans(n_clusters=optimal_k, random_state=42, n_init=10)
clusters = kmeans.fit_predict(X_scaled)

df['cluster'] = clusters

print("✅ Model trained successfully!")

# 6. Analyze clusters
print("\n📊 Cluster Analysis:")
print(f"\nCluster sizes:")
cluster_sizes = df['cluster'].value_counts().sort_index()
for cluster_id, size in cluster_sizes.items():
    pct = size / len(df) * 100
    print(f"   Cluster {cluster_id}: {size} users ({pct:.1f}%)")

# Cluster profiles
print("\n🎯 Cluster Profiles (average values):")
cluster_profiles = df.groupby('cluster')[feature_cols].mean()

for cluster_id in range(optimal_k):
    profile = cluster_profiles.loc[cluster_id]
    print(f"\n  📌 Cluster {cluster_id}:")
    print(f"     Total events: {profile['total_events']:.1f}")
    print(f"     Days with events: {profile['days_with_events']:.1f}")
    print(f"     Purchase events: {profile['purchase_events']:.1f}")
    print(f"     Days since last event: {profile['days_since_last_event']:.1f}")

# 7. Assign segment names based on behavior
segment_names = {}
for cluster_id in range(optimal_k):
    profile = cluster_profiles.loc[cluster_id]
    
    if profile['total_events'] > 30 and profile['purchase_events'] > 2:
        segment_names[cluster_id] = 'Power Users'
    elif profile['total_events'] > 20:
        segment_names[cluster_id] = 'Active Users'
    elif profile['total_events'] > 10:
        segment_names[cluster_id] = 'Casual Users'
    else:
        segment_names[cluster_id] = 'Low Engagement'

df['segment_name'] = df['cluster'].map(segment_names)

print("\n📛 Segment Names:")
for cluster_id, name in segment_names.items():
    size = (df['cluster'] == cluster_id).sum()
    print(f"   Cluster {cluster_id}: {name} ({size} users)")

# 8. Model metrics
silhouette = silhouette_score(X_scaled, clusters)
davies_bouldin = davies_bouldin_score(X_scaled, clusters)

print(f"\n📈 Clustering Metrics:")
print(f"   Silhouette Score: {silhouette:.4f} (higher is better, range -1 to 1)")
print(f"   Davies-Bouldin Index: {davies_bouldin:.4f} (lower is better)")

# 9. Save artifacts
print("\n💾 Saving model artifacts...")

# Save model
with open(output_dir / 'kmeans_segmentation_model.pkl', 'wb') as f:
    pickle.dump(kmeans, f)

# Save scaler
with open(output_dir / 'scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

# Save feature names
with open(output_dir / 'feature_names.txt', 'w') as f:
    f.write('\n'.join(feature_cols))

# Save cluster profiles
cluster_profiles.to_csv(output_dir / 'cluster_profiles.csv')

# Save segment mapping
pd.DataFrame(list(segment_names.items()), columns=['cluster_id', 'segment_name']).to_csv(
    output_dir / 'segment_names.csv', index=False
)

# Save user segments
df[['user_id', 'cluster', 'segment_name']].to_csv(output_dir / 'user_segments.csv', index=False)

# Save metrics
metrics = {
    'n_clusters': optimal_k,
    'total_users': len(df),
    'silhouette_score': float(silhouette),
    'davies_bouldin_score': float(davies_bouldin),
    'cluster_sizes': cluster_sizes.to_dict()
}

import json
with open(output_dir / 'metrics.json', 'w') as f:
    json.dump(metrics, f, indent=2)

print(f"✅ Saved to {output_dir}/")
print(f"   - kmeans_segmentation_model.pkl")
print(f"   - scaler.pkl")
print(f"   - feature_names.txt")
print(f"   - cluster_profiles.csv")
print(f"   - segment_names.csv")
print(f"   - user_segments.csv")
print(f"   - metrics.json")

print("\n" + "=" * 70)
print("✅ CUSTOMER SEGMENTATION MODEL COMPLETE!")
print("=" * 70)
